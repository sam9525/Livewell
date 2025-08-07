import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'signin.dart';
import '../shared/shared.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
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
            ),
            Text(
              'Sign Up',
              style: Shared.fontStyle(24, FontWeight.bold, Shared.orange),
            ),
            Shared.inputContainer(260, 'Username'),
            Shared.inputContainer(260, 'Email'),
            Shared.inputContainer(260, 'Password'),
            Shared.inputContainer(260, 'Confirm Password'),
            TextButton(
              onPressed: () {},
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                  Shared.orange.withOpacity(0.1),
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
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: Shared.buttonStyle(160, 52, Shared.orange, Colors.white),
              child: Text(
                'Sign Up',
                style: Shared.fontStyle(24, FontWeight.bold, Colors.white),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already test have an account?',
                  style: Shared.fontStyle(16, FontWeight.w500, Shared.gray),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInPage(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(
                      Shared.orange.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Shared.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width * 0.9,
              color: Shared.black,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: Shared.thridPartyButtonStyle(160, 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/google.svg',
                        height: 32,
                        width: 32,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Google',
                        style: Shared.fontStyle(
                          16,
                          FontWeight.w500,
                          Shared.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: Shared.thridPartyButtonStyle(160, 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/facebook.svg',
                        height: 32,
                        width: 32,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Facebook',
                        style: Shared.fontStyle(
                          16,
                          FontWeight.w500,
                          Shared.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
