import 'package:http/http.dart' as http;
import '/config/app_config.dart';
import 'dart:convert';
import '../shared/user_provider.dart';
import 'backend_auth.dart';

class ProfileAuth {
  static Future<void> getProfile() async {
    try {
      // Connect to the backend server
      final backendAuthResult = await BackendAuth().authenticateWithBackend(
        UserProvider.userIdToken ?? '',
        AppConfig.googleAuthUrl,
      );

      if (backendAuthResult) {
        // GET the profile from the database
        final response = await http.get(
          Uri.parse(AppConfig.profileUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${UserProvider.userJwtToken}',
          },
        );

        if (response.statusCode == 200) {
          final profile = jsonDecode(response.body);
          UserProvider.userGender = profile['gender'];
          UserProvider.userAgeRange = profile['ageRange'];
        }
      }
    } catch (e) {
      print("Error getting profile: $e");
    }
  }
}
