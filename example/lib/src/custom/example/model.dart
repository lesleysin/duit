import 'package:flutter_duit/flutter_duit.dart';

// Use CustomUiElement instead of DuitElement
final class ExampleCustomWidget extends CustomUiElement {
  ExampleCustomWidget({
    required super.id,
    required super.attributes,
    required super.viewController,
    required super.controlled,
    required super.subviews,
  }) : super(
          tag: "ExampleCustomWidget",
        );
}
