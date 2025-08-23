import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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
    } catch (e) {
      print("Sign out error: $e");
    }
  }
}
