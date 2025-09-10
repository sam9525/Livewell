import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'dart:convert';
import 'backend_auth.dart';
import '../shared/user_provider.dart';

class TrackingAuth {
  static Future<Map<String, dynamic>?> getTracking() async {
    // Authenticate with the backend server
    final backendAuthResult = await BackendAuth().authenticateWithBackend(
      UserProvider.userIdToken ?? '',
      AppConfig.googleAuthUrl,
    );

    if (!backendAuthResult) {
      throw Exception(
        'Failed to authenticate with backend: $backendAuthResult',
      );
    }

    final response = await http.get(
      Uri.parse(AppConfig.trackingTodayUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${UserProvider.userJwtToken}',
      },
    );

    if (response.statusCode == 200) {
      final tracking = jsonDecode(response.body);
      return tracking;
    } else {
      throw Exception('Failed to get tracking: ${response.statusCode}');
    }
  }

  static Future<void> putTodayTracking(int steps, int waterIntakeMl) async {
    // Authenticate with the backend server
    final backendAuthResult = await BackendAuth().authenticateWithBackend(
      UserProvider.userIdToken ?? '',
      AppConfig.googleAuthUrl,
    );

    if (!backendAuthResult) {
      throw Exception(
        'Failed to authenticate with backend: $backendAuthResult',
      );
    }

    final response = await http.put(
      Uri.parse(AppConfig.trackingTodayUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${UserProvider.userJwtToken}',
      },
      body: jsonEncode({'steps': steps, 'waterIntakeMl': waterIntakeMl}),
    );

    if (response.statusCode == 200) {
      print('Tracking updated successfully');
    } else {
      throw Exception('Failed to update tracking: ${response.statusCode}');
    }
  }
}
