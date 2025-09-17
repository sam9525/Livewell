import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/material.dart';
import 'package:livewell_app/shared/shared.dart';
import 'package:livewell_app/shared/shared_preferences_provider.dart';
import 'package:livewell_app/shared/user_provider.dart';
import '../views/signin.dart';
import 'backend_auth.dart';
import 'package:livewell_app/services/notifications_service.dart';

class SignOut {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Facebook
      await _facebookAuth.logOut();

      // Sign out from Firebase
      await _auth.signOut();

      // Backend signout
      await BackendAuth.signOut();

      // Clear the user provider
      SharedPreferencesProvider.getBackgroundPrefs().then((prefs) {
        prefs?.remove('jwt_token');
        prefs?.remove('jwt_token_timestamp');
      });

      UserProvider.userIdToken = null;
      UserProvider.userJwtToken = null;
      UserProvider.userGender = null;
      UserProvider.userAgeRange = null;

      // Cancel all notifications
      NotificationService.cancelAllNotifications();
    } catch (e) {
      throw Exception("Sign out error: $e");
    }
  }

  static Future<void> showSignOutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Shared.bgColor,
        title: Text(
          'Sign Out',
          style: Shared.fontStyle(28, FontWeight.bold, Shared.black),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: Shared.fontStyle(24, FontWeight.bold, Shared.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(
                Shared.orange.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              'Cancel',
              style: Shared.fontStyle(24, FontWeight.bold, Shared.orange),
            ),
          ),
          TextButton(
            onPressed: () async {
              await SignOut().signOut();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => SignInPage()),
                (_) => false,
              );
            },
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(
                Shared.orange.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              'Sign Out',
              style: Shared.fontStyle(24, FontWeight.bold, Shared.orange),
            ),
          ),
        ],
      ),
    );
  }
}
