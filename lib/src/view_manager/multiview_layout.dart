import 'package:duit_kernel/duit_kernel.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:flutter_duit/src/ui/models/ui_tree.dart';

final class _StatefullElement {
  final ElementTree root;
  bool isReady = false;

  _StatefullElement(
    this.root,
    this.isReady,
  );
}

final class DuitMultiViewLayout implements DuitView {
  final _views = <String, _StatefullElement>{};

  @override
  Widget build([String tag = ""]) {
    if (tag.isEmpty || !_views.containsKey(tag)) {
      return _views.values.first.root.render();
    }
    return _views[tag]!.root.render();
  }

  @override
  Future<void> prepareModel(
    Map<String, dynamic> json,
    UIDriver driver,
  ) async {
    final tree = await DuitTree(
      json: json.values.first,
      driver: driver,
    ).parse();

    _views[json.keys.first] = _StatefullElement(tree, false);
  }

  @override
  ElementTree getElementTree([String tag = ""]) {
    if (tag.isEmpty || !_views.containsKey(tag)) {
      return _views.values.first.root;
    }
    return _views[tag]!.root;
  }

  void changeViewState(String tag, int state) {
    if (_views.containsKey(tag)) {
      final elem = _views[tag];

      if (elem != null) {
        elem.isReady = state == 1;
      }
    }
  }

  operator [](String tag) {
    final elem = _views[tag];

    if (elem != null) {
      return (elem.root, elem.isReady);
    }
    return null;
  }
}
