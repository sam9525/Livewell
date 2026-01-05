import 'package:flutter/material.dart';
import 'navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../shared/shared.dart';
import '../auth/signin_with_google.dart';
import '../auth/signin_with_facebook.dart';
import '../shared/sign_in_out_shared.dart';
import 'package:livewell_app/shared/shared_preferences_provider.dart';
import '../shared/user_provider.dart';
import '../services/fcm_service.dart';
import 'survey.dart';

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
      final authResponse = await supabase.Supabase.instance.client.auth
          .signInWithPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Explicitly update UserProvider token to avoid race conditions
      if (authResponse.session != null) {
        UserProvider.userJwtToken = authResponse.session!.accessToken;

        final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
        await prefs?.setString('jwt_token', authResponse.session!.accessToken);
        await prefs?.setString(
          'jwt_token_timestamp',
          DateTime.now().toIso8601String(),
        );

        // Register device
        await FCMService.registerCurrentDevice();
      }

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
                  final result = await _authService.signInWithGoogle();
                  if (context.mounted && result?['user'] != null) {
                    // Register device
                    await FCMService.registerCurrentDevice();

                    if (!context.mounted) return;
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
                      // Register device
                      await FCMService.registerCurrentDevice();

                      if (!context.mounted) return;
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
