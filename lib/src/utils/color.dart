import 'package:flutter/material.dart';

/// Utility class for working with colors in Flutter.
final class ColorUtils {
  /// Tries to parse a color from the given input.
  ///
  /// The `color` parameter can be a [Color] object or a valid HEX color string.
  ///
  /// If `color` is a [Color] object, it is returned as is.
  ///
  /// If `color` is a HEX color string, it is parsed and converted to a [Color] instance.
  /// The HEX color string can start with or without the '#' symbol.
  ///
  /// Throws an [ArgumentError] if the HEX color string is invalid.
  ///
  /// Example usage:
  /// ```dart
  /// Color color1 = ColorUtils.tryParseColor(Colors.blue);
  /// Color color2 = ColorUtils.tryParseColor("#FF0000");
  /// ```
  static Color tryParseColor(dynamic color) {
    if (color is Color) return color;

    ///Parse HEX color string to Color instance
    if (color is String) {
      final isHexColor = color.startsWith("#");
      if (isHexColor) {
        final buffer = StringBuffer();
        if (color.length == 6 || color.length == 7) buffer.write('ff');
        buffer.write(color.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      } else {
        throw ArgumentError("Color must be valid HEX string");
      }
    }

    ///Parse array by fromARGB method to Color instance
    if (color is List<int>) {
      if (color.length == 4) {
        return Color.fromARGB(color[3], color[0], color[1], color[2]);
      } else if (color.length == 3) {
        ///If passed only r g b channels set alpha channel to 1.0 automatically
        return Color.fromARGB(1, color[0], color[1], color[2]);
      } else {
        throw ArgumentError(
            "Color must be valid list of integers with length 4 or 3");
      }
    }

    ///Parse array by fromRGBO method to Color instance
    if (color is List<double>) {
      if (color.length == 4) {
        return Color.fromRGBO(
          color[0].toInt(),
          color[1].toInt(),
          color[2].toInt(),
          color[3],
        );
      } else if (color.length == 3) {
        ///If passed only r g b channels set opacity to 1.0 automatically
        return Color.fromRGBO(
          color[0].toInt(),
          color[1].toInt(),
          color[2].toInt(),
          1.0,
        );
      } else {
        throw ArgumentError("Color must be valid list of double with length 4");
      }
    }

    return Colors.black;
  }
}
