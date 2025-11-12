import 'package:flutter/material.dart';

extension StringColor on String {
  static final _colorCache = <String, Map<double, Color>>{};
  static final customColors = [
    Color(0xFF62E6FF), // Colors.blue,
    Color(0xFF94eeff), // Colors.blueAccent,
    Color(0xFF7DFFB8), // Colors.green,
    Color(0xFFA7FFCE), // Colors.greenAccent,
    Color(0xFFFFD890), // Colors.orange,
    Color(0xFFFF9DFB), // Colors.pink,
    Color(0xFFFFC5FC), // Colors.pinkAccent,
    Color(0xFF9497FF), // Colors.purple,
    Color(0xFF7484FF), // Colors.purpleAccent,
    Color(0xFFD2BBFA), // Colors.lilac,
  ];

  Color _getColorLight(double light) {
    return StringColor.customColors[length % 9];
  }

  Color get color {
    _colorCache[this] ??= {};
    return _colorCache[this]![0.3] ??= _getColorLight(0.3);
  }

  Color get darkColor {
    _colorCache[this] ??= {};
    return _colorCache[this]![0.2] ??= _getColorLight(0.2);
  }

  Color get lightColorText {
    _colorCache[this] ??= {};
    return _colorCache[this]![0.7] ??= _getColorLight(0.7);
  }

  Color get lightColorAvatar {
    _colorCache[this] ??= {};
    return _colorCache[this]![0.45] ??= _getColorLight(0.45);
  }
}
