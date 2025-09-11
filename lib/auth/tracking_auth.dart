import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'dart:convert';
import 'backend_auth.dart';
import '../shared/user_provider.dart';
import 'package:flutter/foundation.dart';

class TrackingAuth {
  static Future<void> checkAuthentication() async {
    if (!BackendAuth().isAuthenticated) {
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
    }
  }

  // Fetch the tracking data for a given week
  static Future<Map<String, dynamic>?> getTracking(
    String startOfWeek,
    String endOfWeek,
  ) async {
    await checkAuthentication();

    String url =
        '${AppConfig.trackingUrl}?start_date=$startOfWeek&end_date=$endOfWeek';

    final response = await http.get(
      Uri.parse(url),
      headers: BackendAuth().getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final tracking = jsonDecode(response.body);
      return tracking;
    } else {
      throw Exception('Failed to get tracking: ${response.statusCode}');
    }
  }

  // Fetch the tracking data for today
  static Future<Map<String, dynamic>?> getTrackingToday() async {
    await checkAuthentication();

    final response = await http.get(
      Uri.parse(AppConfig.trackingTodayUrl),
      headers: BackendAuth().getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final tracking = jsonDecode(response.body);
      return tracking;
    } else {
      throw Exception('Failed to get tracking: ${response.statusCode}');
    }
  }

  // Update the tracking data for today
  static Future<void> putTodayTracking(int steps, int waterIntakeMl) async {
    await checkAuthentication();

    final response = await http.put(
      Uri.parse(AppConfig.trackingTodayUrl),
      headers: BackendAuth().getAuthHeaders(),
      body: jsonEncode({'steps': steps, 'waterIntakeMl': waterIntakeMl}),
    );

    if (response.statusCode == 200) {
      debugPrint('Tracking updated successfully');
    } else {
      throw Exception('Failed to update tracking: ${response.statusCode}');
    }
  }
}
