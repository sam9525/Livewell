import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  UserProvider() {
    // Initialize the user provider
    _user = FirebaseAuth.instance.currentUser;

    // Listen to authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Get current user synchronously
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _user != null;

  // Get user email
  String? get userEmail => _user?.email;

  // Get user display name
  String? get userDisplayName => _user?.displayName;

  // Get user photo URL
  String? get userPhotoURL => _user?.photoURL;

  // Get user created at
  DateTime? get userCreatedAt => _user?.metadata.creationTime;

  // Store user id token
  static String? userIdToken;

  // Store user jwt token
  static String? userJwtToken;

  // Store user gender
  static String? userGender;

  // Store user age range
  static String? userAgeRange;
}
