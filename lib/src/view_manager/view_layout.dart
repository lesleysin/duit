import 'package:duit_kernel/duit_kernel.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:flutter_duit/src/ui/models/ui_tree.dart';

final class DuitViewLayout implements DuitView {
  late ElementTree _layout;
  bool isReady = false;

  @override
  Widget build([String _ = ""]) {
    return _layout.render();
  }

  @override
  Future<void> prepareModel(
    Map<String, dynamic> json,
    UIDriver driver,
  ) async {
    _layout = await DuitTree(
      json: json,
      driver: driver,
    ).parse();
  }

  @override
  ElementTree getElementTree([String tag = ""]) {
    return _layout;
  }
}
