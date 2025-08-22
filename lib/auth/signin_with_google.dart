import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
      final backendAuthResult = await _authenticateWithBackend(idToken);

      if (backendAuthResult) {
        print("Backend authentication successful");
        // Return the authenticated user
        return userCredential.user;
      } else {
        print("Backend authentication failed");

        await signOut();

        return null;
      }
    } catch (e) {
      // Print the error and return null if an exception occurs
      print("Sign-in error: $e");
      return null;
    }
  }

  // Authenticates with the backend server using the Google ID token
  Future<bool> _authenticateWithBackend(String idToken) async {
    bool checkBackend = false;

    // Check if the ID token is null or empty
    if (idToken.isEmpty) {
      print("ID token is null or empty, cannot authenticate with backend");
      return false;
    }

    // Check the health of the backend server
    final healthResponse = await http.get(Uri.parse(AppConfig.healthUrl));
    if (healthResponse.statusCode == 200) checkBackend = true;

    // Authenticate with the backend server
    try {
      final response = await http.post(
        Uri.parse(AppConfig.googleAuthUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.authorizationBearerToken}',
        },
        body: jsonEncode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        return checkBackend;
      } else {
        print(
          "Backend authentication failed with status: ${response.statusCode}",
        );
        print("Response body: ${response.body}");

        checkBackend = false;
      }
    } catch (e) {
      print("Error authenticating with backend: $e");
      checkBackend = false;
    }

    return checkBackend;
  }

  // Signs out the user from both Google and Firebase
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      print("Sign out error: $e");
    }
  }
}
