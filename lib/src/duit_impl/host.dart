import 'package:duit_kernel/duit_kernel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_duit/src/duit_impl/view_context.dart';
import 'package:flutter_duit/src/utils/index.dart';

/// A widget that hosts a DUIT view.
///
/// The `DuitViewHost` widget is responsible for rendering a DUIT view using the provided `UIDriver`.
/// It receives a `placeholder` widget that is displayed while the DUIT view is loading or if there is no data to render.
/// The `driver` parameter is required and should be an instance of `UIDriver`.
/// The `context` parameter is required and should be the build context of the parent widget.
///
/// Example usage:
///
/// ```dart
/// DuitViewHost(
///   driver: myUIDriver,
///   placeholder: CircularProgressIndicator(),
/// )
/// ```
class DuitViewHost extends StatefulWidget {
  /// A widget to be displayed while the DUIT view is loading or if there is no data to render.
  final Widget? placeholder;

  /// The UIDriver that handles the DUIT view.
  final UIDriver driver;

  /// The build context of the parent widget.
  @Deprecated("Will be removed in the next major release")
  final BuildContext? context;

  ///An interceptor function for processing gesture events received using the [GestureDetector] widget.
  ///The handler is triggered for any callback, even if a description of the user action has not
  ///been received from the server.
  final GestureInterceptor? gestureInterceptor;

  ///Determine how the interceptor will be invoked
  ///
  ///[GestureInterceptorBehavior.values] by default
  final GestureInterceptorBehavior gestureInterceptorBehavior;

  ///Child of host view
  final Widget? child;

  ///Determines the order in which widgets will be placed on the stack if a child widget is passed.
  ///
  ///By default, the Duit view will be in the bottom layer of the Stack widget
  final bool invertStack;

  ///Determines whether the passed [child] widget should be shown instead of the [placeholder]
  final bool showChildInsteadOfPlaceholder;

  final Widget Function(BuildContext context, Object? err)? errorWidgetBuilder;

  final String viewTag;

  /// Creates a new `DuitViewHost` widget.
  ///
  /// The [driver] parameter is required and should be an instance of `UIDriver`.
  /// The [context] parameter is required and should be the build context of the parent widget.
  /// The [placeholder] parameter is optional and specifies a widget to be displayed while the DUIT view is loading or if there is no data to render.
  const DuitViewHost({
    super.key,
    required this.driver,
    this.context,
    this.child,
    this.invertStack = false,
    this.showChildInsteadOfPlaceholder = false,
    this.placeholder,
    this.gestureInterceptor,
    this.gestureInterceptorBehavior = GestureInterceptorBehavior.always,
    this.errorWidgetBuilder,
    this.viewTag = "",
  }) : assert(
          showChildInsteadOfPlaceholder == true ? child != null : true,
          "Child must not be null if showChildInsteadOfPlaceholder property is set to true",
        );

  @override
  State<DuitViewHost> createState() => _DuitViewHostState();
}

class _DuitViewHostState extends State<DuitViewHost> {
  @override
  void initState() {
    widget.driver.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.driver.notifyWidgetDisplayStateChanged(widget.viewTag, 0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.driver.eventStream,
      builder: (context, snapshot) {
        widget.driver.context = context;

        if (snapshot.hasError && widget.errorWidgetBuilder != null) {
          return widget.errorWidgetBuilder!.call(context, snapshot.error);
        } else if (snapshot.hasError && widget.errorWidgetBuilder == null) {
          throw snapshot.error!;
        }

        if (snapshot.hasData) {
          final content =
              (snapshot.data as UIDriverViewEvent).model.build(widget.viewTag);

          widget.driver.notifyWidgetDisplayStateChanged(widget.viewTag, 1);

          return DuitViewContext(
            gestureInterceptor: widget.gestureInterceptor,
            gestureInterceptorBehavior: widget.gestureInterceptorBehavior,
            child: _StackWrapper(
              invertStack: widget.invertStack,
              content: content,
              child: widget.child,
            ),
          );
        } else {
          return widget.showChildInsteadOfPlaceholder
              ? widget.child!
              : widget.placeholder ?? const SizedBox.shrink();
        }
      },
    );
  }
}

class _StackWrapper extends StatelessWidget {
  final Widget? child;
  final Widget content;
  final bool invertStack;

  const _StackWrapper({
    required this.child,
    required this.invertStack,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      if (invertStack) {
        return Stack(
          children: [
            child!,
            content,
          ],
        );
      } else {
        return Stack(
          children: [
            content,
            child!,
          ],
        );
      }
    } else {
      return content;
    }
  }
}
