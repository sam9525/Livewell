import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'backend_auth.dart';
import 'sign_out.dart';
import '../config/app_config.dart';
import '../shared/user_provider.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  // FirebaseAuth instance to handle authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GoogleSignIn instance to handle Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Signs in the user with Google and authenticates with the backend server
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();

      // User canceled the sign-in
      if (googleUser == null) return null;

      // Retrieve the authentication details from the Google account
      final googleAuth = await googleUser.authentication;

      // Check if the Google ID token is null BEFORE storing it
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        debugPrint("Google ID token is null");
        return null;
      }

      // Store the user id token in the user provider ONLY if it's not null
      UserProvider.userIdToken = idToken;

      // Start token refresh timer
      BackendAuth.startTokenRefreshTimer();

      // Create a new credential using the Google authentication details
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Return the result if the user is new or not
      final user = userCredential.user;

      bool isNewUser = false;
      final createAt = user!.metadata.creationTime;
      final lastSignInAt = user.metadata.lastSignInTime;

      if (createAt != null && lastSignInAt != null) {
        isNewUser = createAt.isAtSameMomentAs(lastSignInAt);
      }

      // Authenticate with your backend server
      final backendAuthResult = await BackendAuth().authenticateWithBackend(
        idToken,
        AppConfig.googleAuthUrl,
      );

      if (backendAuthResult) {
        debugPrint("Backend authentication successful");
        // Return the authenticated user
        return {'user': userCredential.user, 'isNewUser': isNewUser};
      } else {
        debugPrint("Backend authentication failed");

        await SignOut().signOut();

        return null;
      }
    } catch (e) {
      // Print the error and return null if an exception occurs
      throw Exception("Sign-in error: $e");
    }
  }

  // Add this method to the GoogleAuthService class
  Future<String?> refreshIdToken() async {
    try {
      final googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken != null) {
        UserProvider.userIdToken = idToken;
        return idToken;
      }

      return null;
    } catch (e) {
      debugPrint("Error refreshing ID token: $e");
      return null;
    }
  }
}
