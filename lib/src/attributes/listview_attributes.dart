import 'package:duit_kernel/duit_kernel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_duit/src/utils/index.dart';

final class ListViewAttributes implements DuitAttributes<ListViewAttributes> {
  //<editor-fold desc="Flutter widget props">
  final Axis? scrollDirection;
  final bool? reverse,
      shrinkWrap,
      addSemanticIndexes,
      addRepaintBoundaries,
      addAutomaticKeepAlives,
      primary;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  // final ScrollBehavior? scrollBehavior;
  final double? anchor, cacheExtent, itemExtent;
  final int? semanticChildCount;
  final DragStartBehavior? dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;
  final String? restorationId;
  final Clip? clipBehavior;

  //</editor-fold>

  //<editor-fold desc="Special Duit properties">
  /// 0 - ListView,
  ///
  /// 1 - ListView.builder,
  ///
  /// 2 - ListView.separated
  final int type;
  final String? componentTag, separatorComponentTag;
  final List<JSONObject>? initialData;

  //</editor-fold>

  //<editor-fold desc="Ctor, copy, mapping">
  ListViewAttributes({
    required this.scrollDirection,
    required this.reverse,
    required this.shrinkWrap,
    required this.addSemanticIndexes,
    required this.addRepaintBoundaries,
    required this.addAutomaticKeepAlives,
    required this.primary,
    required this.physics,
    // required this.scrollBehavior,
    required this.anchor,
    required this.cacheExtent,
    required this.semanticChildCount,
    required this.dragStartBehavior,
    required this.keyboardDismissBehavior,
    required this.restorationId,
    required this.clipBehavior,
    required this.padding,
    required this.itemExtent,
  })  : componentTag = null,
        separatorComponentTag = null,
        initialData = null,
        type = 0;

  ListViewAttributes.builder({
    required this.scrollDirection,
    required this.reverse,
    required this.shrinkWrap,
    required this.addSemanticIndexes,
    required this.addRepaintBoundaries,
    required this.addAutomaticKeepAlives,
    required this.primary,
    required this.physics,
    // required this.scrollBehavior,
    required this.anchor,
    required this.cacheExtent,
    required this.semanticChildCount,
    required this.dragStartBehavior,
    required this.keyboardDismissBehavior,
    required this.restorationId,
    required this.clipBehavior,
    required this.padding,
    required this.itemExtent,
    required this.componentTag,
    required this.initialData,
  })  : separatorComponentTag = null,
        type = 1;

  ListViewAttributes.separated({
    required this.scrollDirection,
    required this.reverse,
    required this.shrinkWrap,
    required this.addSemanticIndexes,
    required this.addRepaintBoundaries,
    required this.addAutomaticKeepAlives,
    required this.primary,
    required this.physics,
    // required this.scrollBehavior,
    required this.anchor,
    required this.cacheExtent,
    required this.semanticChildCount,
    required this.dragStartBehavior,
    required this.keyboardDismissBehavior,
    required this.restorationId,
    required this.clipBehavior,
    required this.padding,
    required this.itemExtent,
    required this.componentTag,
    required this.separatorComponentTag,
    required this.initialData,
  }) : type = 2;

  factory ListViewAttributes.fromJson(Map<String, dynamic> json) {
    final type = json["type"] as int;

    switch (type) {
      case 0:
        return ListViewAttributes(
          scrollDirection: ParamsMapper.convertToAxis(json['scrollDirection']),
          reverse: json["reverse"],
          shrinkWrap: json["shrinkWrap"],
          addSemanticIndexes: json["addSemanticIndexes"],
          addRepaintBoundaries: json["addRepaintBoundaries"],
          addAutomaticKeepAlives: json["addAutomaticKeepAlives"],
          primary: json["primary"],
          physics: ParamsMapper.convertToScrollPhysics(json['physics']),
          anchor: NumUtils.toDouble(json["anchor"]),
          cacheExtent: NumUtils.toDouble(json["cacheExtent"]),
          semanticChildCount: NumUtils.toInt(json["semanticChildCount"]),
          dragStartBehavior: ParamsMapper.convertToDragStartBehavior(
              json["dragStartBehavior"]),
          keyboardDismissBehavior:
              ParamsMapper.convertToKeyboardDismissBehavior(
                  json["keyboardDismissBehavior"]),
          restorationId: json["restorationId"],
          clipBehavior: ParamsMapper.convertToClip(json["clipBehavior"]),
          padding: ParamsMapper.convertToEdgeInsets(json["padding"]),
          itemExtent: NumUtils.toDouble(json["itemExtent"]),
        );
      case 1:
        final tag = json["componentTag"];
        assert(tag != null && tag is String,
            "componentTag must be a String and non-null value");
        return ListViewAttributes.builder(
          scrollDirection: ParamsMapper.convertToAxis(json['scrollDirection']),
          reverse: json["reverse"],
          shrinkWrap: json["shrinkWrap"],
          addSemanticIndexes: json["addSemanticIndexes"],
          addRepaintBoundaries: json["addRepaintBoundaries"],
          addAutomaticKeepAlives: json["addAutomaticKeepAlives"],
          primary: json["primary"],
          physics: ParamsMapper.convertToScrollPhysics(json['physics']),
          anchor: NumUtils.toDouble(json["anchor"]),
          cacheExtent: NumUtils.toDouble(json["cacheExtent"]),
          semanticChildCount: NumUtils.toInt(json["semanticChildCount"]),
          dragStartBehavior: ParamsMapper.convertToDragStartBehavior(
              json["dragStartBehavior"]),
          keyboardDismissBehavior:
              ParamsMapper.convertToKeyboardDismissBehavior(
                  json["keyboardDismissBehavior"]),
          restorationId: json["restorationId"],
          clipBehavior: ParamsMapper.convertToClip(json["clipBehavior"]),
          padding: ParamsMapper.convertToEdgeInsets(json["padding"]),
          itemExtent: NumUtils.toDouble(json["itemExtent"]),
          componentTag: tag,
          initialData: json["initialData"],
        );
      case 2:
        final tag = json["componentTag"];
        final separator = json["separatorComponentTag"];
        assert(tag != null && tag is String,
            "componentTag must be a String and non-null value");
        assert(separator != null && separator is String,
            "separatorComponentTag must be a String and non-null value");
        return ListViewAttributes.separated(
          scrollDirection: ParamsMapper.convertToAxis(json['scrollDirection']),
          reverse: json["reverse"],
          shrinkWrap: json["shrinkWrap"],
          addSemanticIndexes: json["addSemanticIndexes"],
          addRepaintBoundaries: json["addRepaintBoundaries"],
          addAutomaticKeepAlives: json["addAutomaticKeepAlives"],
          primary: json["primary"],
          physics: ParamsMapper.convertToScrollPhysics(json['physics']),
          anchor: NumUtils.toDouble(json["anchor"]),
          cacheExtent: NumUtils.toDouble(json["cacheExtent"]),
          semanticChildCount: NumUtils.toInt(json["semanticChildCount"]),
          dragStartBehavior: ParamsMapper.convertToDragStartBehavior(
              json["dragStartBehavior"]),
          keyboardDismissBehavior:
              ParamsMapper.convertToKeyboardDismissBehavior(
                  json["keyboardDismissBehavior"]),
          restorationId: json["restorationId"],
          clipBehavior: ParamsMapper.convertToClip(json["clipBehavior"]),
          padding: ParamsMapper.convertToEdgeInsets(json["padding"]),
          itemExtent: NumUtils.toDouble(json["itemExtent"]),
          separatorComponentTag: separator,
          componentTag: tag,
          initialData: json["initialData"],
        );
      default:
        return ListViewAttributes(
          scrollDirection: ParamsMapper.convertToAxis(json['scrollDirection']),
          reverse: json["reverse"],
          shrinkWrap: json["shrinkWrap"],
          addSemanticIndexes: json["addSemanticIndexes"],
          addRepaintBoundaries: json["addRepaintBoundaries"],
          addAutomaticKeepAlives: json["addAutomaticKeepAlives"],
          primary: json["primary"],
          physics: ParamsMapper.convertToScrollPhysics(json['physics']),
          anchor: NumUtils.toDouble(json["anchor"]),
          cacheExtent: NumUtils.toDouble(json["cacheExtent"]),
          semanticChildCount: NumUtils.toInt(json["semanticChildCount"]),
          dragStartBehavior: ParamsMapper.convertToDragStartBehavior(
              json["dragStartBehavior"]),
          keyboardDismissBehavior:
              ParamsMapper.convertToKeyboardDismissBehavior(
                  json["keyboardDismissBehavior"]),
          restorationId: json["restorationId"],
          clipBehavior: ParamsMapper.convertToClip(json["clipBehavior"]),
          padding: ParamsMapper.convertToEdgeInsets(json["padding"]),
          itemExtent: NumUtils.toDouble(json["itemExtent"]),
        );
    }
  }

  @override
  ListViewAttributes copyWith(ListViewAttributes other) {
    switch (other.type) {
      case 0:
        {
          return ListViewAttributes(
            scrollDirection: other.scrollDirection ?? scrollDirection,
            reverse: other.reverse ?? reverse,
            shrinkWrap: other.shrinkWrap ?? shrinkWrap,
            addSemanticIndexes: other.addSemanticIndexes ?? addSemanticIndexes,
            addRepaintBoundaries:
                other.addRepaintBoundaries ?? addRepaintBoundaries,
            addAutomaticKeepAlives:
                other.addAutomaticKeepAlives ?? addAutomaticKeepAlives,
            primary: other.primary ?? primary,
            physics: other.physics ?? physics,
            anchor: other.anchor ?? anchor,
            cacheExtent: other.cacheExtent ?? cacheExtent,
            semanticChildCount: other.semanticChildCount ?? semanticChildCount,
            dragStartBehavior: other.dragStartBehavior ?? dragStartBehavior,
            keyboardDismissBehavior:
                other.keyboardDismissBehavior ?? keyboardDismissBehavior,
            restorationId: other.restorationId ?? restorationId,
            clipBehavior: other.clipBehavior ?? clipBehavior,
            padding: other.padding ?? padding,
            itemExtent: other.itemExtent ?? itemExtent,
          );
        }
      case 1:
        return ListViewAttributes.builder(
          scrollDirection: other.scrollDirection ?? scrollDirection,
          reverse: other.reverse ?? reverse,
          shrinkWrap: other.shrinkWrap ?? shrinkWrap,
          addSemanticIndexes: other.addSemanticIndexes ?? addSemanticIndexes,
          addRepaintBoundaries:
              other.addRepaintBoundaries ?? addRepaintBoundaries,
          addAutomaticKeepAlives:
              other.addAutomaticKeepAlives ?? addAutomaticKeepAlives,
          primary: other.primary ?? primary,
          physics: other.physics ?? physics,
          anchor: other.anchor ?? anchor,
          cacheExtent: other.cacheExtent ?? cacheExtent,
          semanticChildCount: other.semanticChildCount ?? semanticChildCount,
          dragStartBehavior: other.dragStartBehavior ?? dragStartBehavior,
          keyboardDismissBehavior:
              other.keyboardDismissBehavior ?? keyboardDismissBehavior,
          restorationId: other.restorationId ?? restorationId,
          clipBehavior: other.clipBehavior ?? clipBehavior,
          componentTag: other.componentTag ?? componentTag,
          padding: other.padding ?? padding,
          itemExtent: other.itemExtent ?? itemExtent,
          initialData: other.initialData ?? initialData,
        );
      case 2:
        return ListViewAttributes.separated(
          scrollDirection: other.scrollDirection ?? scrollDirection,
          reverse: other.reverse ?? reverse,
          shrinkWrap: other.shrinkWrap ?? shrinkWrap,
          addSemanticIndexes: other.addSemanticIndexes ?? addSemanticIndexes,
          addRepaintBoundaries:
              other.addRepaintBoundaries ?? addRepaintBoundaries,
          addAutomaticKeepAlives:
              other.addAutomaticKeepAlives ?? addAutomaticKeepAlives,
          primary: other.primary ?? primary,
          physics: other.physics ?? physics,
          anchor: other.anchor ?? anchor,
          cacheExtent: other.cacheExtent ?? cacheExtent,
          semanticChildCount: other.semanticChildCount ?? semanticChildCount,
          dragStartBehavior: other.dragStartBehavior ?? dragStartBehavior,
          keyboardDismissBehavior:
              other.keyboardDismissBehavior ?? keyboardDismissBehavior,
          restorationId: other.restorationId ?? restorationId,
          clipBehavior: other.clipBehavior ?? clipBehavior,
          componentTag: other.componentTag ?? componentTag,
          separatorComponentTag:
              other.separatorComponentTag ?? separatorComponentTag,
          padding: other.padding ?? padding,
          itemExtent: other.itemExtent ?? itemExtent,
          initialData: other.initialData ?? initialData,
        );
      default:
        return ListViewAttributes(
          scrollDirection: other.scrollDirection ?? scrollDirection,
          reverse: other.reverse ?? reverse,
          shrinkWrap: other.shrinkWrap ?? shrinkWrap,
          addSemanticIndexes: other.addSemanticIndexes ?? addSemanticIndexes,
          addRepaintBoundaries:
              other.addRepaintBoundaries ?? addRepaintBoundaries,
          addAutomaticKeepAlives:
              other.addAutomaticKeepAlives ?? addAutomaticKeepAlives,
          primary: other.primary ?? primary,
          physics: other.physics ?? physics,
          anchor: other.anchor ?? anchor,
          cacheExtent: other.cacheExtent ?? cacheExtent,
          semanticChildCount: other.semanticChildCount ?? semanticChildCount,
          dragStartBehavior: other.dragStartBehavior ?? dragStartBehavior,
          keyboardDismissBehavior:
              other.keyboardDismissBehavior ?? keyboardDismissBehavior,
          restorationId: other.restorationId ?? restorationId,
          clipBehavior: other.clipBehavior ?? clipBehavior,
          padding: other.padding ?? padding,
          itemExtent: other.itemExtent ?? itemExtent,
        );
    }
  }
//</editor-fold>
}
