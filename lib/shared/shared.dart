import 'package:flutter/material.dart';

class Shared {
  // Colors
  static const Color orange = Color(0xFFEB5E28);
  static const Color black = Color(0xFF1E1E1E);
  static const Color gray = Color(0xFF4F4F4F);
  static const Color lightGray = Color(0xFFC0C0C0);
  static const Color bgColor = Color(0xFFFFFCF2);

  // Text Styles
  static TextStyle fontStyle(double size, FontWeight weight, Color color) =>
      TextStyle(fontSize: size, fontWeight: weight, color: color);

  // Button Styles
  static ButtonStyle buttonStyle(
    double width,
    double height,
    Color bgColor,
    Color fgColor,
  ) => ElevatedButton.styleFrom(
    backgroundColor: bgColor,
    foregroundColor: fgColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    fixedSize: Size(width, height),
    elevation: 5,
  );
}
