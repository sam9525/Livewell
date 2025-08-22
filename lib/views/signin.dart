import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../shared/shared.dart';
import 'signup.dart';
import '../auth/signin_with_google.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obscureText = true;

  // Google Auth Service
  final GoogleAuthService _authService = GoogleAuthService();

  void toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  // Sign in user
  Future<void> signIn() async {
    try {
      await supabase.Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on supabase.AuthException catch (e) {
      Shared.showCredentialsDialog(context, e.message, mounted);
    }
  }

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
              'Sign In',
              style: Shared.fontStyle(24, FontWeight.bold, Shared.orange),
            ),
            Shared.inputContainer(260, 'Email', emailController),
            Shared.inputContainer(
              260,
              'Password',
              passwordController,
              obscureText: obscureText,
              toggle: toggle,
            ),
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
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                signIn();
              },
              style: Shared.buttonStyle(160, 52, Shared.orange, Colors.white),
              child: Text(
                'Sign In',
                style: Shared.fontStyle(24, FontWeight.bold, Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an account?',
                  style: Shared.fontStyle(16, FontWeight.w500, Shared.gray),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(
                      Shared.orange.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
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
                  onPressed: () async {
                    User? user = await _authService.signInWithGoogle();
                    if (user != null) {
                      // Navigate to the home page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage()),
                      );
                    }
                  },
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
