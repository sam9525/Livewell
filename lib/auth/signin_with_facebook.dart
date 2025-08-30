import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'backend_auth.dart';
import 'sign_out.dart';
import '../config/app_config.dart';

class SignInWithFacebook {
  // FacebookAuth instance to handle Facebook Sign-In
  final FacebookAuth _fbAuth = FacebookAuth.instance;

  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      // Trigger the Facebook Sign-In flow
      final fbUser = await _fbAuth.login(
        permissions: ['email', 'public_profile'],
      );

      final accessToken = fbUser.accessToken!.tokenString;

      // Create a new credential using the access token
      final credential = FacebookAuthProvider.credential(accessToken);

      // Log in with the credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      // Return the if the user is new or not
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      // Authenticate with the backend server
      final backendAuthResult = await BackendAuth().authenticateWithBackend(
        accessToken,
        AppConfig.facebookAuthUrl,
      );

      if (backendAuthResult) {
        print("Backend authentication successful");
        // Return the authenticated user
        return {'user': userCredential.user, 'isNewUser': isNewUser};
      } else {
        print("Backend authentication failed");

        await SignOut().signOut();

        return null;
      }
    } catch (e) {
      print("Sign-in error: $e");
      return null;
    }
  }
}
