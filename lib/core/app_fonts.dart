import 'package:flutter/material.dart';

class GoogleFonts {
  static TextStyle dmSans({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    List<FontFeature>? fontFeatures,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: fontFeatures,
    );
  }

  static TextTheme dmSansTextTheme(TextTheme textTheme) => textTheme;
}