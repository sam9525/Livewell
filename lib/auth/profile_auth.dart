import 'package:http/http.dart' as http;
import '/config/app_config.dart';
import 'dart:convert';
import '../shared/user_provider.dart';
import 'backend_auth.dart';
import '../shared/shared_preferences_provider.dart';

class ProfileAuth {
  static Future<void> getProfile() async {
    try {
      // Connect to the backend server
      final backendAuthResult = await BackendAuth().authenticateWithBackend(
        UserProvider.userIdToken ??
            // Get the jwt token from the shared preferences
            SharedPreferencesProvider.backgroundPrefs?.getString('jwt_token') ??
            '',
        AppConfig.googleAuthUrl,
      );

      if (backendAuthResult) {
        // GET the profile from the database
        final response = await http.get(
          Uri.parse(AppConfig.profileUrl),
          headers: BackendAuth().getAuthHeaders(),
        );

        if (response.statusCode == 200) {
          final profile = jsonDecode(response.body);
          UserProvider.userGender = profile['gender'];
          UserProvider.userAgeRange = profile['ageRange'];
        }
      }
    } catch (e) {
      throw Exception("Error getting profile: $e");
    }
  }
}
