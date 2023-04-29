library uuid_to_hsl;

import 'dart:math';

import 'package:flutter/rendering.dart';

class UuidToHsl {
  static Color getColorFromUUID(String uuid) {
    double hue = _getHueFromUuid(uuid);
    HSLColor hslColor = HSLColor.fromAHSL(0.9, hue, 0.9, 0.35);
    Color color = hslColor.toColor();
    return color;
  }

  static HSLColor getHSLColorFromUUID(
      String uuid, double alpha, double saturation, double lightness) {
    double hue = _getHueFromUuid(uuid);
    HSLColor hslColor = HSLColor.fromAHSL(0.9, hue, 0.9, 0.35);
    return hslColor;
  }

  static double _getHueFromUuid(String uuid) {
    // Get hex value from second and last characters of uuid
    // Add '1' to each value to avoid 0 after conversion to int
    // Min value is 1, max value is 16
    final secondChar = uuid[1];
    final secondCharByte = int.parse(secondChar, radix: 16) + 1;
    final lastChar = uuid[31];
    final lastCharByte = int.parse(lastChar, radix: 16) + 1;
    // Now we need a random value generated from those two bytes.
    // Multiplying or summing them will not work, as product or sum will
    // have a normal distribution.
    // Hence, we need to use a trigonometric function and calulate the angle
    // between the two bytes using arctangens.
    double angle = atan(secondCharByte / lastCharByte);
    // the arctangens can have a min val of -pi/2 and a max val of pi/2 theoretically
    // in practice with positive integers [1,16] it will be between ¬4 and ¬86 degrees.
    // The distribution of angles between 4 and 86 should be much more uniform,
    // given produced from two random integers between 1 and 16.

    // Now we need to convert the angle to a hue value.
    // Hue value is between 0 and 360 in Flutter.
    double hue = (angle * 229.3);

    return hue;
  }
}
