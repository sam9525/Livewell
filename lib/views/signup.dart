import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'survey.dart';
import 'signin.dart';
import '../shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../auth/signin_with_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/signin_with_facebook.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool obscureText = true;

  // Google Auth Service
  final GoogleAuthService _authService = GoogleAuthService();

  // Facebook Auth Service
  final SignInWithFacebook _facebookAuthService = SignInWithFacebook();

  void toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  // Sign up user
  Future<void> signUp() async {
    try {
      if (passwordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        Shared.showCredentialsDialog(
          context,
          'Passwords do not match',
          mounted,
        );
        return;
      }

      await supabase.Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check if the user is signed up
      if (!mounted) return;

      // Create a new user profile in the database
      await supabase.Supabase.instance.client.from('profile').insert({
        'uuid': supabase.Supabase.instance.client.auth.currentUser?.id,
        'username': usernameController.text.trim(),
      });

      // Navigate to the survey page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SurveyPage()),
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
              'Sign Up',
              style: Shared.fontStyle(24, FontWeight.bold, Shared.orange),
            ),
            Shared.inputContainer(260, 'Username', usernameController),
            Shared.inputContainer(260, 'Email', emailController),
            Shared.inputContainer(
              260,
              'Password',
              passwordController,
              obscureText: obscureText,
              toggle: toggle,
            ),
            Shared.inputContainer(
              260,
              'Confirm Password',
              confirmPasswordController,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                signUp();
              },
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
                  'Already have an account?',
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
                  onPressed: () async {
                    User? user = await _authService.signInWithGoogle();
                    if (user != null) {
                      // Navigate to the survey page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SurveyPage()),
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
                  onPressed: () async {
                    User? user = await _facebookAuthService
                        .signInWithFacebook();
                    if (user != null) {
                      // Navigate to the survey page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SurveyPage()),
                      );
                    }
                  },
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
