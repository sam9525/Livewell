import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class BackendAuth {
  // Authenticates with the backend server using the Google ID token
  Future<bool> authenticateWithBackend(String idToken, String url) async {
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
        Uri.parse(url),
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
}
