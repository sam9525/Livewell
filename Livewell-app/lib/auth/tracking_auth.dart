import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:livewell_app/shared/shared_preferences_provider.dart';
import 'package:livewell_app/shared/user_provider.dart';
import '../config/app_config.dart';
import 'dart:convert';
import 'backend_auth.dart';
import 'package:flutter/foundation.dart';

class TrackingAuth {
  // Fetch the tracking data for a given week
  static Future<List<Map<String, dynamic>>?> getTracking(
    String startOfWeek,
    String endOfWeek,
  ) async {
    String url =
        '${UserProvider.instance?.isEmailSignedIn == true ? AppConfig.trackingEmailUrl : AppConfig.trackingGoogleUrl}?start_date=$startOfWeek&end_date=$endOfWeek';

    final response = await http.get(
      Uri.parse(url),
      headers: BackendAuth().getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      var tracking = jsonDecode(response.body);
      debugPrint('Tracking: $tracking');
      if (tracking is List && tracking.isNotEmpty) {
        return List<Map<String, dynamic>>.from(tracking);
      }
      return null;
    } else {
      throw Exception('Failed to get tracking: ${response.statusCode}');
    }
  }

  // Fetch the tracking data for today
  static Future<Map<String, dynamic>?> getTrackingToday() async {
    final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
    final isEmail = prefs?.getBool('is_email_signed_in') ?? false;

    final response = await http.get(
      Uri.parse(
        isEmail
            ? AppConfig.trackingTodayEmailUrl
            : AppConfig.trackingTodayGoogleUrl,
      ),
      headers: BackendAuth().getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      var tracking = jsonDecode(response.body);

      if (tracking is List && tracking.isNotEmpty) {
        tracking = tracking.first;
      }

      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      prefs?.setInt(
        'current_water_intake',
        tracking['current_water_intake_ml'],
      );
      prefs?.setInt('target_water_intake', tracking['target_water_intake_ml']);
      prefs?.setInt('target_steps', tracking['target_steps']);
      return tracking as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get tracking: ${response.statusCode}');
    }
  }

  // Update the tracking data for today
  static Future<bool> putTodayTracking(int steps, int waterIntakeMl) async {
    final response = await http.put(
      Uri.parse(
        UserProvider.instance?.isEmailSignedIn == true
            ? AppConfig.trackingTodayEmailUrl
            : AppConfig.trackingTodayGoogleUrl,
      ),
      headers: BackendAuth().getAuthHeaders(),
      body: jsonEncode({
        'current_steps': steps,
        'current_water_intake_ml': waterIntakeMl,
      }),
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
        Uri.parse(
          UserProvider.instance?.isEmailSignedIn == true
              ? AppConfig.trackingTodayEmailUrl
              : AppConfig.trackingTodayGoogleUrl,
        ),
        headers: authHeaders,
        body: jsonEncode({
          'current_steps': steps,
          'current_water_intake_ml': waterIntakeMl,
        }),
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
    int targetWaterIntakeMl, {
    bool isBackground = false,
  }) async {
    try {
      if (isBackground) {
        try {
          await dotenv.load(fileName: ".env");
        } catch (e) {
          debugPrint('dotenv load failed: $e');
        }
      }

      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      final isEmail = prefs?.getBool('is_email_signed_in') ?? false;

      final response = await http.put(
        Uri.parse(
          isEmail
              ? isBackground
                    ? dotenv.get('TRACKING_TODAY_TARGET_EMAIL_URL')
                    : AppConfig.trackingTodayTargetEmailUrl
              : isBackground
              ? dotenv.get('TRACKING_TODAY_TARGET_GOOGLE_URL')
              : AppConfig.trackingTodayTargetGoogleUrl,
        ),
        headers: BackendAuth().getAuthHeaders(),
        body: jsonEncode({
          'target_steps': targetSteps,
          'target_water_intake_ml': targetWaterIntakeMl,
        }),
      );

      if (response.statusCode == 200) {
        prefs?.setInt('target_water_intake', targetWaterIntakeMl);
        prefs?.setInt('target_steps', targetSteps);
        await getTrackingToday();
        return true;
      } else {
        debugPrint('Failed to update tracking targets: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error in tracking targets update: $e');
      return false;
    }
  }
}
