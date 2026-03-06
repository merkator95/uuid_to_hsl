// Not required for test files
// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:uuid_to_hsl/uuid_to_hsl.dart';

const kTestUuid = '4248057c-bb2f-46c7-960b-71474cc863fc';
const kExpColor = 4283392460;

void main() {
  group('UuidToHsl', () {
    test('can be instantiated', () {
      expect(UuidToHsl(), isNotNull);
    });

    test('handles invalid uuid', () {
      final col = UuidToHsl().colorFromUuid('1234567890');
      expect(
        col,
        isA<Color>(),
      );
    });

    test('returns the same color for the same uuid', () {
      final color = UuidToHsl().colorFromUuid(kTestUuid);
      expect(color, Color(kExpColor));
    });
  });
}
