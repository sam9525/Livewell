import 'package:flutter/material.dart';
import 'navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../shared/shared.dart';
import '../auth/signin_with_google.dart';
import '../auth/signin_with_facebook.dart';
import '../shared/sign_in_out_shared.dart';

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

  // Facebook Auth Service
  final SignInWithFacebook _facebookAuthService = SignInWithFacebook();

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

      SignInOutShared.changePage(context, const HomePage());
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
            SignInOutShared.forgotPassword(context),
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
                SignInOutShared.signUpOrSignIn(context, 'Sign Up'),
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
                  final user = await _authService.signInWithGoogle();
                  if (context.mounted && user != null) {
                    SignInOutShared.changePage(context, const HomePage());
                  }
                }),
                SizedBox(width: 16),
                SignInOutShared.thirdPartyButtons(
                  'facebook',
                  'Facebook',
                  () async {
                    final user = await _facebookAuthService
                        .signInWithFacebook();
                    if (context.mounted && user != null) {
                      SignInOutShared.changePage(context, const HomePage());
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
