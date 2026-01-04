import 'package:http/http.dart' as http;
import 'package:livewell_app/shared/shared_preferences_provider.dart';
import '../config/app_config.dart';
import 'dart:convert';
import 'backend_auth.dart';
import 'package:flutter/foundation.dart';

class TrackingAuth {
  // Fetch the tracking data for a given week
  static Future<Map<String, dynamic>?> getTracking(
    String startOfWeek,
    String endOfWeek,
  ) async {
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
    final response = await http.get(
      Uri.parse(AppConfig.trackingTodayUrl),
      headers: BackendAuth().getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final tracking = jsonDecode(response.body);
      debugPrint('Tracking: $tracking');

      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      prefs?.setInt('current_water_intake', tracking['currentWaterIntakeMl']);
      prefs?.setInt('target_water_intake', tracking['targetWaterIntakeMl']);
      return tracking;
    } else {
      throw Exception('Failed to get tracking: ${response.statusCode}');
    }
  }

  // Update the tracking data for today
  static Future<bool> putTodayTracking(int steps, int waterIntakeMl) async {
    final response = await http.put(
      Uri.parse(AppConfig.trackingTodayUrl),
      headers: BackendAuth().getAuthHeaders(),
      body: jsonEncode({'steps': steps, 'waterIntakeMl': waterIntakeMl}),
    );
    getTrackingToday();

    if (response.statusCode == 200) {
      debugPrint('Tracking updated successfully');
      return true;
    } else {
      throw Exception('Failed to update tracking: ${response.statusCode}');
    }
  }

  // Update the tracking data for today on background
  static Future<bool> putTodayTrackingBackground(
    int steps,
    int waterIntakeMl,
  ) async {
    try {
      // Try to authenticate with stored token first
      bool authenticated = await BackendAuth.authenticateWithStoredToken();

      if (!authenticated) {
        debugPrint('Background authentication failed - no valid stored token');
        return false;
      }

      final authHeaders = await BackendAuth.getStoredAuthHeaders();
      if (authHeaders == null) {
        debugPrint('Background authentication failed - no auth headers');
        return false;
      }

      final response = await http.put(
        Uri.parse(AppConfig.trackingTodayUrl),
        headers: authHeaders,
        body: jsonEncode({'steps': steps, 'waterIntakeMl': waterIntakeMl}),
      );

      await getTrackingToday();

      if (response.statusCode == 200) {
        debugPrint('Background tracking updated successfully');
        return true;
      } else {
        debugPrint('Background tracking update failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error in background tracking update: $e');
      return false;
    }
  }

  static Future<bool> putTodayTrackingTargets(
    int targetSteps,
    int targetWaterIntakeMl,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(AppConfig.trackingTodayTargetUrl),
        headers: BackendAuth().getAuthHeaders(),
        body: jsonEncode({
          'targetSteps': targetSteps,
          'targetWaterIntakeMl': targetWaterIntakeMl,
        }),
      );
      getTrackingToday();

      if (response.statusCode == 200) {
        debugPrint('Tracking updated successfully');

        final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
        prefs?.setInt('target_water_intake', targetWaterIntakeMl);

        return true;
      } else {
        throw Exception('Failed to update tracking: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in background tracking update: $e');
      return false;
    }
  }
}
