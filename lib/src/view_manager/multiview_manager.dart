import 'package:duit_kernel/duit_kernel.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:flutter_duit/src/view_manager/view_manager.dart';
import 'package:flutter_duit/src/view_manager/multiview_layout.dart';
import 'package:flutter_duit/src/view_manager/simple_manager.dart';

/// A [ViewManager] for managing multiple views. Provides backward compatibility with [SimpleViewManager].
final class MultiViewManager extends SimpleViewManager {
  late DuitMultiViewLayout _layout;

  MultiViewManager();

  @override
  Widget build([String tag = ""]) {
    return _layout.build(tag);
  }

  @override
  Future<DuitView?> prepareLayout(Map<String, dynamic> json) async {
    try {
      final compatView = await super.prepareLayout(json);

      if (compatView == null) {
        _layout = DuitMultiViewLayout();

        if (json
            case {
              "widgets": Map collection,
            }) {
          final widgets = collection.entries.cast<MapEntry<String, dynamic>>();

          for (final widget in widgets) {
          await _layout.prepareModel(
              <String, dynamic>{
                widget.key: widget.value,
              },
            driver,
          );
          }

          return _layout;
        }
        return null;
      }
      return compatView;
    } catch (e, s) {
      driver.logger?.error(
        "Failed to resolve tree",
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  void notifyWidgetDisplayStateChanged(
    String viewTag,
    int state,
  ) {
    _layout.changeViewState(viewTag, state);
  }

  @override
  bool isWidgetReady(String viewTag) {
    if (_layout[viewTag] == null) {
      return false;
    } else {
      return _layout[viewTag]!.isReady;
    }
  }
}
