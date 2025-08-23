import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'backend_auth.dart';
import 'sign_out.dart';
import '../config/app_config.dart';

class GoogleAuthService {
  // FirebaseAuth instance to handle authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GoogleSignIn instance to handle Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Signs in the user with Google and authenticates with the backend server
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();

      // User canceled the sign-in
      if (googleUser == null) return null;

      // Retrieve the authentication details from the Google account
      final googleAuth = await googleUser.authentication;

      // Check if the Google ID token is null
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        print("Google ID token is null");
        return null;
      }

      // Create a new credential using the Google authentication details
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Authenticate with your backend server
      final backendAuthResult = await BackendAuth().authenticateWithBackend(
        idToken,
        AppConfig.googleAuthUrl,
      );

      if (backendAuthResult) {
        print("Backend authentication successful");
        // Return the authenticated user
        return userCredential.user;
      } else {
        print("Backend authentication failed");

        await SignOut().signOut();

        return null;
      }
    } catch (e) {
      // Print the error and return null if an exception occurs
      print("Sign-in error: $e");
      return null;
    }
  }
}
