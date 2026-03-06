import 'dart:convert';
import 'dart:math';

import 'package:flutter/rendering.dart';

part '_uuid_to_hsl_v1.dart';

class _HslParts {
  const _HslParts({
    required this.hue,
    required this.saturation,
    required this.lightness,
  });

  final double hue;
  final double saturation;
  final double lightness;
}

class UuidToHsl {
  const UuidToHsl({
    this.brandHue,
    this.avoidDeg = 22,
    this.sMin = 0.5,
    this.sMax = 0.55,
    this.lMin = 0.5,
    this.lMax = 0.6,
  });

  final double? brandHue;
  final double avoidDeg;

  final double sMin;
  final double sMax;
  final double lMin;
  final double lMax;

  HSLColor hslColorFromUuid(String uuid) {
    final parts = _partsFor(uuid);
    return HSLColor.fromAHSL(1, parts.hue, parts.saturation, parts.lightness);
  }

  Color colorFromUuid(String uuid) {
    return hslColorFromUuid(uuid).toColor();
  }

  double getHueFromUuid(String uuid) => _partsFor(uuid).hue;

  double getSatFromUuid(String uuid) => _partsFor(uuid).saturation;

  double getLightFromUuid(String uuid) => _partsFor(uuid).lightness;

  _HslParts _partsFor(String value) {
    final bytes = _stableBytes(value);

    final hHash = _fnv1a32(bytes, seed: 0x811C9DC5);
    final sHash = _fnv1a32(bytes, seed: 0x27D4EB2D);
    final lHash = _fnv1a32(bytes, seed: 0x165667B1);

    var hue = (hHash % 360).toDouble();
    if (brandHue != null) {
      hue = _pushHueOutOfBand(hue, brandHue!, avoidDeg);
    }

    final saturation = sMin + (sMax - sMin) * _unit(sHash);
    final lightness = lMin + (lMax - lMin) * _unit(lHash);

    return _HslParts(
      hue: hue,
      saturation: saturation,
      lightness: lightness,
    );
  }

  static int _fnv1a32(List<int> data, {required int seed}) {
    var h = seed & 0xFFFFFFFF;
    for (final b in data) {
      h ^= b;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }

  static double _unit(int x) => (x & 0xFFFFFFFF) / 0xFFFFFFFF;

  List<int> _stableBytes(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return utf8.encode('__empty__');
    }

    final hexCandidate = trimmed.replaceAll('-', '').toLowerCase();
    if (_is32CharHex(hexCandidate)) {
      return _hexToBytes(hexCandidate);
    }

    return utf8.encode(trimmed);
  }

  bool _is32CharHex(String s) {
    if (s.length != 32) return false;

    for (var i = 0; i < s.length; i++) {
      final c = s.codeUnitAt(i);
      final isDigit = c >= 48 && c <= 57; // 0-9
      final isLowerHex = c >= 97 && c <= 102; // a-f

      if (!isDigit && !isLowerHex) {
        return false;
      }
    }

    return true;
  }

  List<int> _hexToBytes(String hex) {
    final bytes = <int>[];

    for (var i = 0; i < 32; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }

    return bytes;
  }

  double _pushHueOutOfBand(double hue, double center, double halfWidth) {
    double circularDist(double a, double b) {
      final d = (a - b).abs();
      return d > 180 ? 360 - d : d;
    }

    final d = circularDist(hue, center);
    if (d >= halfWidth) return hue;

    var delta = hue - center;
    while (delta <= -180) {
      delta += 360;
    }
    while (delta > 180) {
      delta -= 360;
    }

    final pushed = delta >= 0 ? (center + halfWidth) : (center - halfWidth);
    return (pushed % 360 + 360) % 360;
  }

  @deprecated
  static Color getColorFromUUID(String uuid) =>
      _UuidToHslV1.getColorFromUUID(uuid);

  @deprecated
  static HSLColor getHSLColorFromUUID(
    String uuid,
    double alpha,
    double saturation,
    double lightness,
  ) => _UuidToHslV1.getHSLColorFromUUID(uuid, alpha, saturation, lightness);
}
