import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/app_config.dart';
import '../shared/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:livewell_app/shared/shared_preferences_provider.dart';
import 'signin_with_google.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class BackendAuth {
  // Make it a singleton
  static final BackendAuth _instance = BackendAuth._internal();
  factory BackendAuth() => _instance;
  BackendAuth._internal();

  bool isAuthenticated = false;
  Timer? _tokenRefreshTimer;

  // Store JWT token persistently
  static Future<void> storeJwtToken(String jwtToken) async {
    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      await prefs?.setString('jwt_token', jwtToken);
      await prefs?.setString(
        'jwt_token_timestamp',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error storing JWT token: $e');
    }
  }

  // Retrieve JWT token from persistent storage
  static Future<String?> getStoredJwtToken() async {
    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      return prefs?.getString('jwt_token') ?? UserProvider.userJwtToken;
    } catch (e) {
      debugPrint('Error retrieving JWT token: $e');
      return null;
    }
  }

  // Check if stored JWT token is still valid (not expired)
  static Future<bool> isStoredTokenValid() async {
    try {
      final shouldRefresh = await shouldRefreshToken();

      if (shouldRefresh) {
        debugPrint('Token is expired, attempting to refresh...');
        final refreshSuccess = await BackendAuth().refreshJwtToken();
        return refreshSuccess;
      }

      return !shouldRefresh;
    } catch (e) {
      debugPrint('Error checking token validity: $e');
      return false;
    }
  }

  // Check if token needs refresh (within threshold time of expiry)
  static Future<bool> shouldRefreshToken() async {
    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      String token = prefs?.getString('jwt_token') ?? '';
      DateTime expiryDate = JwtDecoder.getExpirationDate(token);
      Duration timeLeft = expiryDate.difference(DateTime.now());
      debugPrint('Time left: ${timeLeft.inMinutes} minutes');

      return timeLeft.inMinutes < 1;
    } catch (e) {
      debugPrint('Error checking if token should refresh: $e');
      return true;
    }
  }

  // Start automatic token refresh timer
  static void startTokenRefreshTimer() {
    BackendAuth()._stopTokenRefreshTimer();

    // Check every 5 minutes if token needs refresh
    BackendAuth()._tokenRefreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) async {
        await BackendAuth()._checkAndRefreshToken();
      },
    );

    debugPrint('Token refresh timer started');
  }

  // Stop automatic token refresh timer
  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  // Check and refresh token if needed
  Future<void> _checkAndRefreshToken() async {
    try {
      if (!isAuthenticated) return;

      final shouldRefresh = await shouldRefreshToken();
      if (shouldRefresh) {
        debugPrint('Token needs refresh, attempting to refresh...');
        await refreshJwtToken();
      }
    } catch (e) {
      debugPrint('Error in token refresh check: $e');
    }
  }

  // Refresh JWT token using Google ID token
  Future<bool> refreshJwtToken() async {
    try {
      debugPrint('Attempting to refresh JWT token...');

      // Get fresh Google ID token
      final googleAuthService = GoogleAuthService();
      final idToken = await googleAuthService.refreshIdToken();

      if (idToken == null || idToken.isEmpty) {
        debugPrint('Failed to get fresh Google ID token');
        return false;
      }

      // Authenticate with backend using fresh ID token
      final success = await authenticateWithBackend(
        idToken,
        AppConfig.googleAuthUrl,
      );

      if (success) {
        debugPrint('JWT token refreshed successfully');
        startTokenRefreshTimer();
        return true;
      } else {
        debugPrint('Failed to refresh JWT token with backend');
        return false;
      }
    } catch (e) {
      debugPrint('Error refreshing JWT token: $e');
      return false;
    }
  }

  // Authenticates with the backend server using the Google ID token
  Future<bool> authenticateWithBackend(String idToken, String url) async {
    // Check if the ID token is null or empty
    if (idToken.isEmpty) {
      debugPrint("ID token is null or empty, cannot authenticate with backend");
      return false;
    }

    // Check the health of the backend server
    final healthResponse = await http.get(Uri.parse(AppConfig.healthUrl));
    if (healthResponse.statusCode != 200) {
      return false;
    }

    // Authenticate with the backend server
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Store the JWT token in UserProvider and persistently
        UserProvider.userJwtToken = responseBody;
        await storeJwtToken(responseBody);

        isAuthenticated = true;
        return true;
      } else {
        debugPrint(
          "Backend authentication failed with status: ${response.statusCode}",
        );
        debugPrint("Response body: ${response.body}");

        return false;
      }
    } catch (e) {
      throw Exception("Error authenticating with backend: $e");
    }
  }

  // Method to get headers for API calls
  Map<String, String> getAuthHeaders() {
    // Get the jwt token from the shared preferences
    final jwtToken =
        UserProvider.userJwtToken ??
        SharedPreferencesProvider.backgroundPrefs?.getString('jwt_token') ??
        '';

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    };
  }

  // Authenticate using stored JWT token (for background operations)
  static Future<bool> authenticateWithStoredToken() async {
    try {
      final storedToken = await getStoredJwtToken();
      if (storedToken == null) {
        debugPrint('No stored JWT token found');
        return false;
      }

      final isValid = await isStoredTokenValid();
      if (!isValid) {
        debugPrint('Stored JWT token is expired');
        return false;
      }

      // Set the stored token in UserProvider
      UserProvider.userJwtToken = storedToken;
      BackendAuth().isAuthenticated = true;

      return true;
    } catch (e) {
      debugPrint('Error authenticating with stored token: $e');
      return false;
    }
  }

  // Get auth headers using stored token (for background operations)
  static Future<Map<String, String>?> getStoredAuthHeaders() async {
    try {
      final storedToken = await getStoredJwtToken();
      if (storedToken == null) {
        debugPrint('No stored JWT token available');
        return null;
      }

      final isValid = await isStoredTokenValid();
      if (!isValid) {
        debugPrint('Stored JWT token is expired');
        return null;
      }

      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $storedToken',
      };
    } catch (e) {
      debugPrint('Error getting stored auth headers: $e');
      return null;
    }
  }

  // Delete stored JWT token
  static Future<void> deleteStoredJwtToken() async {
    final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
    await prefs?.remove('jwt_token');
    await prefs?.remove('jwt_token_timestamp');
    debugPrint('Stored JWT token deleted');
  }

  // Sign out and cleanup
  static Future<void> signOut() async {
    BackendAuth()._stopTokenRefreshTimer();
    BackendAuth().isAuthenticated = false;
    UserProvider.userJwtToken = null;
    await deleteStoredJwtToken();
    debugPrint('User signed out and token refresh stopped');
  }

  // Dispose method to cleanup resources
  static void dispose() {
    BackendAuth()._stopTokenRefreshTimer();
  }
}
