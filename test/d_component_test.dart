import "package:flutter/material.dart";
import "package:flutter_duit/flutter_duit.dart";
import "package:flutter_duit/src/ui/widgets/empty.dart";
import "package:flutter_test/flutter_test.dart";

import "mocks/component_template.dart";

void main() {
  DuitRegistry.registerComponents([componentTemplate]);

  group("DuitComponent widget tests", () {
    testWidgets("must merge with data correctly", (tester) async {
      final driver = DuitDriver.static(
        {
          "type": "Component",
          "id": "comp1",
          "tag": "x",
          "data": componentTemplateData,
        },
        transportOptions: HttpTransportOptions(),
        enableDevMetrics: false,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DuitViewHost(
            driver: driver,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final cont1 = find.byKey(const Key("container1"));
      expect(cont1, findsOneWidget);
    });

    testWidgets("must use default value", (tester) async {
      final driver = DuitDriver.static(
        {
          "type": "Component",
          "id": "comp1",
          "tag": "x",
          "data": componentTemplateData2,
        },
        transportOptions: HttpTransportOptions(),
        enableDevMetrics: false,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DuitViewHost(
            driver: driver,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final containerWithDefaultColorValue =
          find.byKey(const Key("container2"));
      expect(containerWithDefaultColorValue, findsOneWidget);
      expect(
        (tester.firstWidget(containerWithDefaultColorValue) as Container).color,
        ColorUtils.tryParseColor("#DCDCDC"),
      );
    });

    testWidgets("must return empty view when tag is invalid", (tester) async {
      final driver = DuitDriver.static(
        {
          "type": "Component",
          "id": "comp1",
          "tag": "invalid_tag",
          "data": componentTemplateData2,
        },
        transportOptions: HttpTransportOptions(),
        enableDevMetrics: false,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DuitViewHost(
            driver: driver,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final emptyWidget = find.byType(DuitEmptyView);
      expect(emptyWidget, findsOneWidget);
    });

    testWidgets("must update component state", (tester) async {
      final driver = DuitDriver.static(
        {
          "type": "Component",
          "id": "testId",
          "controlled": true,
          "tag": "x",
          "data": componentTemplateData,
        },
        transportOptions: HttpTransportOptions(),
        enableDevMetrics: false,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DuitViewHost(
            driver: driver,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await driver.updateTestAttributes(
        "testId",
        componentUpdateTemplateData,
      );

      await tester.pumpAndSettle();

      final container = find.byType(Container);

      expect(container, findsWidgets);

      final fCont = container.first.evaluate().first.widget as Container;

      expect(fCont.color, ColorUtils.tryParseColor("#DCDCDC"));
    });

    testWidgets("must register embedded component", (tester) async {
      final driver = DuitDriver.static(
        {
          "embedded": [
            componentTemplate2,
          ],
          "type": "Column",
          "id": "column1",
          "controlled": false,
          "attributes": {},
          "children": [
            {
              "type": "Component",
              "id": "testId1",
              "controlled": true,
              "tag": "x",
              "data": componentTemplateData,
            },
            {
              "type": "Component",
              "id": "testId2",
              "controlled": true,
              "tag": "y",
              "data": componentTemplateData,
            }
          ],
        },
        transportOptions: HttpTransportOptions(),
        enableDevMetrics: false,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DuitViewHost(
            driver: driver,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = find.byKey(const ValueKey("target_container"));

      expect(container, findsWidgets);
    });
  });
}
