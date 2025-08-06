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

  // Input Container
  static Container inputContainer(double width, String hintText) => Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    width: width,
    child: TextField(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: lightGray,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: black, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: orange, width: 3),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
  );

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

  // Third Party Button Styles
  static ButtonStyle thridPartyButtonStyle(double width, double height) =>
      ElevatedButton.styleFrom(
        fixedSize: Size(width, height),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: const Color(0xFF1E1E1E), width: 1),
        ),
      );
}
