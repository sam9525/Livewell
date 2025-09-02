import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Shared {
  // Colors
  static const Color orange = Color(0xFFCD4813);
  static const Color black = Color(0xFF1E1E1E);
  static const Color gray = Color(0xFF4F4F4F);
  static const Color lightGray2 = Color(0xFFEDEDED);
  static const Color lightGray = Color(0xFFC0C0C0);
  static const Color darkGray = Color(0xFF626262);
  static const Color bgColor = Color(0xFFFFFCF2);

  // Text Styles
  static TextStyle fontStyle(double size, FontWeight weight, Color color) =>
      TextStyle(fontSize: size, fontWeight: weight, color: color);

  // Input Container
  static Container inputContainer(
    double width,
    String hintText,
    TextEditingController? controller, {
    bool obscureText = false,
    Function()? toggle,
    Color fontColor = lightGray,
    bool enabled = true,
    Function(String)? onSubmitted,
  }) => Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    width: width,
    child: TextField(
      controller: controller,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      obscureText: obscureText,
      enabled: enabled,
      textAlignVertical: TextAlignVertical.center,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.w500,
          fontSize: 24,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: black, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: black, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: orange, width: 3),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: hintText == 'Password' || hintText == 'Confirm Password'
            ? IconButton(
                onPressed: toggle,
                color: orange,
                icon: SvgPicture.asset(
                  obscureText
                      ? 'assets/icons/closed_eye.svg'
                      : 'assets/icons/open_eye.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(orange, BlendMode.srcIn),
                ),
              )
            : null,
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

  static void showCredentialsDialog(
    BuildContext context,
    String message,
    bool mounted,
  ) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: Shared.orange.withOpacity(0.1),
        content: Text(
          message,
          style: Shared.fontStyle(20, FontWeight.w500, Shared.orange),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: Text(
              'OK',
              style: Shared.fontStyle(20, FontWeight.bold, Shared.orange),
            ),
          ),
        ],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      ),
    );

    // Hide the MaterialBanner after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }
}

class AppConstants {
  // Week day abbreviations
  static const List<String> weekDays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  // Month abbreviations
  static const List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}
