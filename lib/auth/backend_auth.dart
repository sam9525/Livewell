import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../shared/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:livewell_app/shared/shared_preferences_provider.dart';

class BackendAuth {
  // Make it a singleton
  static final BackendAuth _instance = BackendAuth._internal();
  factory BackendAuth() => _instance;
  BackendAuth._internal();

  bool isAuthenticated = false;

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
      return prefs?.getString('jwt_token');
    } catch (e) {
      debugPrint('Error retrieving JWT token: $e');
      return null;
    }
  }

  // Check if stored JWT token is still valid (not expired)
  static Future<bool> isStoredTokenValid() async {
    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      final timestampStr = prefs?.getString('jwt_token_timestamp');
      if (timestampStr == null) return false;

      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      // Consider token valid for 24 hours
      return difference.inHours < 24;
    } catch (e) {
      debugPrint('Error checking token validity: $e');
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
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.authorizationBearerToken}',
        },
        body: jsonEncode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Store the JWT token in UserProvider and persistently
        UserProvider.userJwtToken = responseBody['token'];
        await storeJwtToken(responseBody['token']);

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
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${UserProvider.userJwtToken}',
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
}
