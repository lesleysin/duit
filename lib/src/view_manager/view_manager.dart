import 'package:duit_kernel/duit_kernel.dart';
import 'package:flutter/material.dart';

/// The `ViewManager` class provides the foundational interface for preparing and building views.
/// It holds a reference to a `UIDriver`, which is used to drive the rendering and interaction
/// of the views. Subclasses of `ViewManager` are expected to implement specific logic for
/// preparing layouts and building the corresponding Flutter widgets.
///
/// Methods:
///
/// - `prepareLayout`: Asynchronously prepares a `DuitView` from a given JSON model. This method
///   is intended to be overridden by subclasses to provide specific layout preparation logic.
///
/// - `build`: Constructs a Flutter `Widget` representation of the view. This method can be
///   overridden by subclasses to provide custom widget-building logic based on a tag.
abstract base class ViewManager implements WidgetDisplayStateNotifier {
  late final UIDriver driver;

  Future<DuitView?> prepareLayout(Map<String, dynamic> json);

  Widget build([String tag = ""]);

  @override
  void notifyWidgetDisplayStateChanged(
    String viewTag,
    int state,
  );

  void addController(String id, UIElementController controller);

  UIElementController? removeController(String id);

  UIElementController? getController(String id);

  int get controllersCount;
}
