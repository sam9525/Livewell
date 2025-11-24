import 'package:flutter/material.dart';
import 'package:livewell_app/views/navigation.dart';
import 'survey.dart';
import '../shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../auth/signin_with_google.dart';
import '../auth/signin_with_facebook.dart';
import '../shared/sign_in_out_shared.dart';

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

      if (!mounted) return;
      // Navigate to the survey page
      SignInOutShared.changePage(context, const SurveyPage());
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
            SignInOutShared.header(),
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
            SignInOutShared.forgotPassword(context),
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
                SignInOutShared.signUpOrSignIn(context, 'Sign In'),
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
                SignInOutShared.thirdPartyButtons('google', 'Google', () async {
                  final result = await _authService.signInWithGoogle();
                  if (context.mounted && result?['user'] != null) {
                    SignInOutShared.changePage(
                      context,
                      result?['isNewUser']
                          ? const SurveyPage()
                          : const HomePage(),
                    );
                  }
                }),
                SizedBox(width: 16),
                SignInOutShared.thirdPartyButtons(
                  'facebook',
                  'Facebook',
                  () async {
                    final result = await _facebookAuthService
                        .signInWithFacebook();
                    if (context.mounted && result?['user'] != null) {
                      SignInOutShared.changePage(
                        context,
                        result?['isNewUser']
                            ? const SurveyPage()
                            : const HomePage(),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
