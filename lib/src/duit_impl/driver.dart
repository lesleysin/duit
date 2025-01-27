import "dart:async";

import "package:duit_kernel/duit_kernel.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_duit/flutter_duit.dart";
import "package:flutter_duit/src/duit_impl/hooks.dart";
import "package:flutter_duit/src/view_manager/index.dart";
import "package:flutter_duit/src/transport/index.dart";
import "package:flutter_duit/src/ui/models/element_type.dart";
import "package:flutter_duit/src/utils/index.dart";

final class DuitDriver with DriverHooks implements UIDriver {
  @protected
  @override
  final String source;

  @override
  Transport? transport;

  @protected
  @override
  TransportOptions transportOptions;

  @override
  @Deprecated("Use eventStreamController instead")
  StreamController<ElementTree?> streamController =
      StreamController.broadcast();

  @protected
  @override
  late BuildContext buildContext;

  @override
  set context(BuildContext value) {
    buildContext = value;
  }

  @override
  StreamController<UIDriverEvent> eventStreamController =
      StreamController.broadcast();

  @override
  Stream<UIDriverEvent> get eventStream => eventStreamController.stream;

  @override
  ExternalEventHandler? externalEventHandler;

  @override
  ScriptRunner? scriptRunner;

  @override
  @Deprecated("Use eventStream instead")
  Stream<ElementTree?> get stream =>
      streamController.stream.asBroadcastStream();

  @protected
  final Map<String, dynamic>? initialRequestPayload;

  late final bool _useStaticContent;
  bool _isChannelInitialized = false, _isDriverInitialized = false;

  late final Map<String, dynamic>? content;

  @override
  late final ActionExecutor actionExecutor;

  @override
  late final EventResolver eventResolver;

  @override
  MethodChannel? driverChannel;

  @override
  late final bool isModule;

  @override
  late DebugLogger? logger;

  late ViewManager _viewManager;

  DuitDriver(
    this.source, {
    required this.transportOptions,
    this.externalEventHandler,
    this.initialRequestPayload,
    this.logger,
    EventResolver? customEventResolver,
    ActionExecutor? customActionExecutor,
    DebugLogger? customLogger,
    bool enableDevMetrics = false,
    bool shared = false,
  }) {
    logger = customLogger ?? DefaultLogger.instance;

    _useStaticContent = false;
    actionExecutor = customActionExecutor ??
        DefaultActionExecutor(
          driver: this,
          logger: logger,
        );
    eventResolver = customEventResolver ??
        DefaultEventResolver(
          driver: this,
          logger: logger,
        );
    isModule = false;
    _viewManager = shared ? MultiViewManager() : SimpleViewManager();
  }

  /// Creates a new instance of [DuitDriver] with the specified [content] without establishing a initial transport connection.
  DuitDriver.static(
    this.content, {
    required this.transportOptions,
    this.externalEventHandler,
    this.logger,
    EventResolver? customEventResolver,
    ActionExecutor? customActionExecutor,
    DebugLogger? customLogger,
    bool enableDevMetrics = false,
    this.source = "",
    this.initialRequestPayload,
    bool shared = false,
  }) {
    logger = customLogger ?? DefaultLogger.instance;

    _useStaticContent = true;
    isModule = false;
    eventResolver = customEventResolver ??
        DefaultEventResolver(
          driver: this,
          logger: logger,
        );
    actionExecutor = customActionExecutor ??
        DefaultActionExecutor(
          driver: this,
          logger: logger,
        );
    _viewManager = shared ? MultiViewManager() : SimpleViewManager();
  }

  /// Creates a new [DuitDriver] instance that is controlled from native code
  DuitDriver.module()
      : _useStaticContent = false,
        source = "",
        initialRequestPayload = null,
        isModule = true,
        externalEventHandler = null,
        transportOptions = EmptyTransportOptions(),
        driverChannel = const MethodChannel("duit:driver"),
        _viewManager = SimpleViewManager();

  //</editor-fold">

  //<editor-fold desc="Controller related methods">
  @protected
  @override
  void attachController(String id, UIElementController controller) {
    _viewManager.addController(id, controller);
    // final hasController = _viewControllers.containsKey(id);
    // assert(!hasController,
    //     "ViewController with id already exists. You cannot attach controller to driver because it  contains element for id ($id)");
    // _viewControllers[id] = controller;
  }

  @protected
  @override
  void detachController(String id) =>
      _viewManager.removeController(id)?.dispose();

  @protected
  @override
  UIElementController? getController(String id) =>
      _viewManager.getController(id);

  Future<Map<String, dynamic>> _connect() async {
    Map<String, dynamic>? json;

    try {
      if (_useStaticContent) {
        assert(content != null && content!.isNotEmpty);
        json = content!;
      } else {
        json = await transport?.connect(
          initialData: initialRequestPayload,
        );
      }
    } catch (e, s) {
      logger?.error(
        "Failed conneting to server",
        error: e,
        stackTrace: s,
      );
      eventStreamController.sink.addError(e);
    }

    if (transport is Streamer) {
      final streamer = transport as Streamer;
      streamer.eventStream.listen(
        (d) async {
          try {
            if (buildContext.mounted) {
              await eventResolver.resolveEvent(buildContext, d);
            }
          } catch (e, s) {
            logger?.error(
              "Error while processing event from transport stream",
              error: e,
              stackTrace: s,
            );
            eventStreamController.sink.addError(e);
          }
        },
      );
    }

    return json ?? {};
  }

  @override
  Future<void> init() async {
    if (!_isDriverInitialized) {
      _isDriverInitialized = true;
    } else {
      return;
    }

    _viewManager.driver = this;
    _addParsers();

    onInit?.call();

    if (isModule && !_isChannelInitialized) {
      await _initMethodChannel();
    }

    transport ??= _getTransport(
      transportOptions.type,
    );

    await scriptRunner?.initWithTransport(transport!);

    final json = await _connect();

    try {
      final view = await _viewManager.prepareLayout(json);

      if (view != null) {
        eventStreamController.sink.add(
          UIDriverViewEvent(view),
        );
      } else {
        final err = FormatException(
            "Invalid layout structure. Received map keys: ${json.keys}");
        throw err;
      }
    } catch (e, s) {
      logger?.error(
        "Layout parse failed",
        error: e,
        stackTrace: s,
      );
      eventStreamController.addError(
        UIDriverErrorEvent(
          "Layout parse failed",
          error: e,
          stackTrace: s,
        ),
      );
    }
  }

  @override
  void dispose() {
    onDispose?.call();
    transport?.dispose();
    // _viewControllers
    //   ..forEach((_, c) => c.dispose())
    //   ..clear();
    eventStreamController.close();
  }

  @override
  Widget? build() {
    return _viewManager.build();
  }

  void _addParsers() {
    try {
      ViewAttribute.attributeParser = DefaultAttributeParser();
      ServerAction.setActionParser(DefaultActionParser());
      ServerEvent.eventParser = DefaultEventParser();
    } catch (e) {
      //Safely handle the case of assigning parsers during
      //multiple driver initializations as part of running tests
      logger?.warn(
        e.toString(),
      );
    }
  }

  //</editor-fold>

  //<editor-fold desc="Actions & Events">

  @override
  Future<void> execute(ServerAction action) async {
    beforeActionCallback?.call(action);

    try {
      final event = await actionExecutor.executeAction(
        action,
      );

      if (event != null && buildContext.mounted) {
        eventResolver.resolveEvent(buildContext, event);
      }
    } catch (e) {
      logger?.error(
        "Error executing action",
        error: e,
      );
    } finally {
      afterActionCallback?.call();
    }
  }

  Future<void> _resolveComponentUpdate(
    UIElementController controller,
    JSONObject json,
  ) async {
    final tag = controller.tag;
    final description = DuitRegistry.getComponentDescription(tag!);

    if (description != null) {
      final component = JsonUtils.mergeWithDataSource(
        description,
        json,
      );

      final attributes = ViewAttribute.createAttributes(
        ElementType.subtree,
        component,
        tag,
      );

      controller.updateState(attributes);
    }
  }

  @protected
  @override
  Future<void> evalScript(String source) async {
    await scriptRunner?.eval(source);
  }

  // </editor-fold>

  //<editor-fold desc="Transport methods">
  /// Returns a transport based on the specified transport type.
  ///
  /// This method is used internally to create and return a transport object based
  /// on the specified [type]. It switches on the [type] parameter and returns an
  /// instance of the corresponding transport class.
  ///
  /// Parameters:
  /// - [type]: The transport type.
  ///
  /// Returns:
  /// - An instance of the transport class based on the specified [type].
  /// - If the [type] is not recognized, it returns an instance of [HttpTransport].
  Transport _getTransport(String type) {
    if (isModule) {
      return NativeTransport(this);
    }

    switch (type) {
      case TransportType.http:
        {
          return HttpTransport(
            source,
            options: transportOptions as HttpTransportOptions,
          );
        }
      case TransportType.ws:
        {
          return WSTransport(
            source,
            options: transportOptions as WebSocketTransportOptions,
          );
        }
      default:
        {
          return EmptyTransport();
        }
    }
  }

  /// Initializes the driver as a module.
  Future<void> _initMethodChannel() async {
    driverChannel?.setMethodCallHandler((call) async {
      switch (call.method) {
        case "duit_event":
          await eventResolver.resolveEvent(
            buildContext,
            call.arguments as Map<String, dynamic>,
          );
          break;
        case "duit_layout":
          final json = call.arguments as Map<String, dynamic>;
          final view = await _viewManager.prepareLayout(json);
          if (view != null) {
            eventStreamController.sink.add(
              UIDriverViewEvent(view),
            );
          }
          break;
        default:
          break;
      }
    });
    _isChannelInitialized = true;
  }

  // </editor-fold">

  //<editor-fold desc="Testing">
  @visibleForTesting
  Future<void> updateTestAttributes(
    String id,
    Map<String, dynamic> json,
  ) =>
      updateAttributes(
        id,
        json,
      );

  @visibleForTesting
  Future<void> executeTestAction(ServerAction action) async {
    await execute(action);
  }

  @visibleForTesting
  Future<void> resolveTestEvent(dynamic eventData) async {
    await eventResolver.resolveEvent(buildContext, eventData);
  }

  @visibleForTesting
  int get controllersCount => _viewManager.controllersCount;

  @override
  Map<String, dynamic> preparePayload(
    Iterable<ActionDependency> dependencies,
  ) {
    final Map<String, dynamic> payload = {};

    if (dependencies.isNotEmpty) {
      for (final dependency in dependencies) {
        final controller = _viewManager.getController(dependency.id);
        if (controller != null) {
          final attribute = controller.attributes.payload;
          if (attribute is AttendedModel) {
            payload[dependency.target] = attribute.collect();
          }
        }
      }
    }

    return payload;
  }

  @override
  Future<void> updateAttributes(
    String controllerId,
    Map<String, dynamic> json,
  ) async {
    final controller = _viewManager.getController(controllerId);
    if (controller != null) {
      if (controller.type == ElementType.component) {
        await _resolveComponentUpdate(controller, json);
        return;
      }

      final attributes = ViewAttribute.createAttributes(
        controller.type,
        json,
        controller.tag,
      );

      controller.updateState(attributes);
    }
  }

  @override
  void notifyWidgetDisplayStateChanged(
    String viewTag,
    int state,
  ) {
    _viewManager.notifyWidgetDisplayStateChanged(viewTag, state);
    logger?.info("Widget $viewTag state changed to $state");
  }

  @override
  bool isWidgetReady(String viewTag) {
    return _viewManager.isWidgetReady(viewTag);
  }
//</editor-fold>
}
