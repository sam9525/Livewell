import 'package:http/http.dart' as http;
import '/config/app_config.dart';
import 'dart:convert';
import '../shared/user_provider.dart';
import 'backend_auth.dart';
import '../shared/shared_preferences_provider.dart';
import 'package:flutter/foundation.dart';

class ProfileAuth {
  static Future<void> getProfile() async {
    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();

      // First, try to authenticate with stored token if not already authenticated
      if (!BackendAuth().isAuthenticated) {
        final storedAuthSuccess =
            await BackendAuth.authenticateWithStoredToken();
        if (!storedAuthSuccess) {
          // If stored token authentication fails, try with fresh token
          final backendAuthResult = await BackendAuth().authenticateWithBackend(
            UserProvider.userIdToken ??
                // Get the jwt token from the shared preferences
                prefs?.getString('jwt_token') ??
                '',
            AppConfig.googleAuthUrl,
          );

          if (!backendAuthResult) {
            throw Exception("Failed to authenticate with backend");
          }
        }
      }

      // GET the profile from the database
      final response = await http.get(
        Uri.parse(AppConfig.profileUrl),
        headers: BackendAuth().getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final profile = jsonDecode(response.body);
        UserProvider.userGender = profile['gender'];
        UserProvider.userAgeRange = profile['ageRange'];

        debugPrint('Profile get successfully');
      } else {
        debugPrint('Failed to get profile: ${response.statusCode}');
        throw Exception("Failed to get profile: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error getting profile: $e");
    }
  }

  static Future<bool> updateLocation(String suburb, String postcode) async {
    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();

      // Authenticate if not already authenticated
      if (!BackendAuth().isAuthenticated) {
        final storedAuthSuccess =
            await BackendAuth.authenticateWithStoredToken();
        if (!storedAuthSuccess) {
          final backendAuthResult = await BackendAuth().authenticateWithBackend(
            UserProvider.userIdToken ?? prefs?.getString('jwt_token') ?? '',
            AppConfig.googleAuthUrl,
          );

          if (!backendAuthResult) {
            debugPrint("Failed to authenticate with backend");
            return false;
          }
        }
      }

      // PUT request to update location data
      final response = await http.put(
        Uri.parse(AppConfig.profileUrl),
        headers: BackendAuth().getAuthHeaders(),
        body: jsonEncode({'suburb': suburb, 'postcode': postcode}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to update location: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
      return false;
    }
  }
}
