import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livewell_app/shared/shared.dart';
import 'package:livewell_app/views/signin.dart';
import 'package:livewell_app/views/signup.dart';

class SignInOutShared {
  // Header
  static Widget header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome to ',
          style: Shared.fontStyle(32, FontWeight.bold, Shared.black),
        ),
        Text(
          'LiveWell',
          style: Shared.fontStyle(32, FontWeight.bold, Shared.orange),
        ),
      ],
    );
  }

  // Forgot Password
  static Widget forgotPassword(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(
          Shared.orange.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: const Color(0xFF1E1E1E),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // Sign up or Sign in
  static Widget signUpOrSignIn(BuildContext context, String text) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                text == 'Sign Up' ? const SignUpPage() : const SignInPage(),
          ),
        );
      },
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(
          Shared.orange.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Shared.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // Third Party Buttons
  static Widget thirdPartyButtons(
    String icon,
    String text,
    Function() onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: Shared.thridPartyButtonStyle(160, 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/$icon.svg', height: 32, width: 32),
          SizedBox(width: 8),
          Text(
            text,
            style: Shared.fontStyle(16, FontWeight.w500, Shared.black),
          ),
        ],
      ),
    );
  }

  // Change page
  static Future<void> changePage(BuildContext context, Widget page) async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (_) => false,
    );
  }
}
