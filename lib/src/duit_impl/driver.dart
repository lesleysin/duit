import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_duit/flutter_duit.dart";
import "package:flutter_duit/src/transport/index.dart";
import "package:flutter_duit/src/ui/models/attended_model.dart";
import "package:flutter_duit/src/ui/models/ui_tree.dart";
import "package:flutter_duit/src/utils/index.dart";

import "event.dart";

abstract interface class UIDriver {
  abstract final String source;
  abstract final TransportOptions transportOptions;
  abstract Transport? transport;
  abstract BuildContext _context;
  abstract StreamController<DUITAbstractTree?> _streamController;

  void attachController(String id, UIElementController controller);

  Future<void> init();

  Widget? build();

  Future<void> execute(ServerAction action);

  void dispose();

  set context(BuildContext value);

  Stream<DUITAbstractTree?> get stream;
}

final class DUITDriver implements UIDriver {
  @override
  final String source;
  @override
  Transport? transport;
  @override
  TransportOptions transportOptions;
  @override
  late StreamController<DUITAbstractTree?> _streamController;
  @override
  late BuildContext _context;

  DUITAbstractTree? _layout;
  Map<String, UIElementController> _viewControllers = {};

  @override
  set context(BuildContext value) {
    _context = value;
  }

  @override
  Stream<DUITAbstractTree?> get stream => _streamController.stream;

  DUITDriver(
    this.source, {
    required this.transportOptions,
  });

  @override
  void attachController(String id, UIElementController controller) {
    final hasController = _viewControllers.containsKey(id);
    assert(!hasController,
        "ViewController with id already exists. You cannot attach controller to driver because it  contains element for id ($id)");

    _viewControllers[id] = controller;
  }

  Transport _getTransport(TransportType type) {
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
          return HttpTransport(
            source,
            options: transportOptions as HttpTransportOptions,
          );
        }
    }
  }

  FutureOr<void> _resolveEventFromJson(JSONObject? json) async {
    final event = ServerEvent.fromJson(json);

    if (event != null) {
      switch (event.type) {
        case ServerEventType.update:
          final updEvent = event as UpdateEvent;
          updEvent.updates.forEach((key, value) {
            updateAttributes(key, value);
          });
          break;
      }
    }
  }

  FutureOr<void> _resolveEvent(ServerEvent event) async {
    switch (event.type) {
      case ServerEventType.update:
        final updEvent = event as UpdateEvent;
        updEvent.updates.forEach((key, value) {
          updateAttributes(key, value);
        });
        break;
    }
  }

  @override
  Future<void> init() async {
    _streamController = StreamController();
    transport = _getTransport(transportOptions.type);
    final json = await transport?.connect();
    assert(json != null);

    if (transport is Streamer) {
      final streamer = transport as Streamer;
      streamer.eventStream.listen(_resolveEventFromJson);
    }

    _layout = await DUITAbstractTree(json: json!, driver: this).parse();
    _streamController.sink.add(_layout);
  }

  @override
  Widget? build() {
    return _layout?.render();
  }

  @override
  Future<void> execute(ServerAction action) async {
    final Map<String, dynamic> payload = {};

    final dependencies = action.dependsOn;

    if (dependencies.isNotEmpty) {
      for (final dependency in dependencies) {
        final controller = _viewControllers[dependency.id];
        if (controller != null) {
          if (controller.attributes?.payload is AttendedModel) {
            final model = controller.attributes?.payload as AttendedModel;
            payload[dependency.target] = model.collect();
          }
        }
      }
    }

    final event = await transport?.execute(action, payload);
    //case with http request
    if (event != null) {
      _resolveEvent(event);
    }
  }

  @override
  void dispose() {
    transport?.dispose();
    _viewControllers = {};
    _layout = null;
    _streamController.close();
  }

  void updateAttributes(String id, JSONObject json) {
    final controller = _viewControllers[id];
    if (controller != null) {
      final attributes = ViewAttributeWrapper.createAttributes(
        controller.type,
        json,
        controller.tag,
      );
      controller.updateState(attributes);
    }
  }
}
