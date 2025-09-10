import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../shared/user_provider.dart';
import 'package:flutter/foundation.dart';

class BackendAuth {
  // Make it a singleton
  static final BackendAuth _instance = BackendAuth._internal();
  factory BackendAuth() => _instance;
  BackendAuth._internal();

  bool isAuthenticated = false;

  // Authenticates with the backend server using the Google ID token
  Future<bool> authenticateWithBackend(String idToken, String url) async {
    // Check if the user is already authenticated and the token is valid
    if (isAuthenticated) {
      return true;
    }

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

        // Store the JWT token UserProvider
        UserProvider.userJwtToken = responseBody['token'];

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
}
