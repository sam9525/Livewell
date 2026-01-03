import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class UserProvider extends ChangeNotifier {
  // Singleton-like reference to the active provider instance in the widget tree
  static UserProvider? instance;

  User? _user;
  User? get user => _user;

  UserProvider() {
    // Capture current instance for access outside widget context (e.g., services)
    instance = this;
    // Initialize the user provider
    _user = FirebaseAuth.instance.currentUser;
    _updateCreatedAt();

    // Listen to authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      _updateCreatedAt();
      notifyListeners();
    });

    // Initialize Supabase user
    final supabaseUser = supabase.Supabase.instance.client.auth.currentUser;
    _isEmailSignedIn =
        supabaseUser != null &&
        supabaseUser.appMetadata['providers'] == 'email';

    if (supabaseUser != null) {
      _updateCreatedAt();
      _updateUserJwtToken();
    }

    // Listen to Supabase auth state changes
    supabase.Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final bool isSignedIn =
          data.session != null &&
          data.session!.user.appMetadata['provider'] == 'email';
      bool shouldNotify = false;

      if (_isEmailSignedIn != isSignedIn) {
        _isEmailSignedIn = isSignedIn;
        _updateCreatedAt();
        shouldNotify = true;
      }

      final String? newToken = data.session?.accessToken;
      if (_jwtToken != newToken) {
        _jwtToken = newToken;
        shouldNotify = true;
      }

      if (shouldNotify) {
        notifyListeners();
      }
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
  String? _createdAt;
  String? get userCreatedAt => _createdAt;

  void _updateCreatedAt() {
    if (_user != null) {
      _createdAt = _user!.metadata.creationTime
          ?.toIso8601String()
          .split('T')
          .first;
    } else {
      final user = supabase.Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _createdAt = user.createdAt;
      } else {
        _createdAt = null;
      }
    }
  }

  // Get user frailty score
  static double? userFrailtyScore;

  // Update user frailty score
  void updateFrailtyScore(double score) {
    userFrailtyScore = score;
    notifyListeners();
  }

  // Check if user is signed in with email
  bool _isEmailSignedIn = false;
  bool get isEmailSignedIn => _isEmailSignedIn;

  // Store user id token
  static String? userIdToken;

  String? _jwtToken;
  String? get jwtToken => _jwtToken;

  // Static proxy for backward compatibility and external access
  static String? get userJwtToken => instance?._jwtToken;
  static set userJwtToken(String? value) {
    if (instance != null) {
      instance!._jwtToken = value;
      instance!.notifyListeners();
    }
  }

  void _updateUserJwtToken() {
    _jwtToken =
        supabase.Supabase.instance.client.auth.currentSession?.accessToken;
    notifyListeners();
  }

  // Store user gender
  static String? userGender;

  // Store user age range
  static String? userAgeRange;
}
