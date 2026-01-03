import 'package:http/http.dart' as http;
import '/config/app_config.dart';
import 'dart:convert';
import '../shared/user_provider.dart';
import 'backend_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileAuth {
  static Future<void> getProfile() async {
    try {
      // GET the profile from the database
      final response = await http.get(
        Uri.parse(
          UserProvider.instance?.isEmailSignedIn == true
              ? AppConfig.profileEmailUrl
              : AppConfig.profileGoogleUrl,
        ),
        headers: BackendAuth().getAuthHeaders(),
      );
      debugPrint('Profile get response: ${response.body}');

      if (response.statusCode == 200) {
        final profile = jsonDecode(response.body);
        final data = profile is List ? profile[0] : profile['data'];
        UserProvider.userGender = data['gender'];
        UserProvider.userAgeRange = data['ageRange'];
        UserProvider.userFrailtyScore = data['frailtyScore'];

        debugPrint('Profile get successfully');
        return profile;
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
      // PUT request to update location data
      final response = await http.put(
        Uri.parse(
          UserProvider.instance?.isEmailSignedIn == true
              ? AppConfig.profileEmailUrl
              : AppConfig.profileGoogleUrl,
        ),
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

  static Future<bool> updateFrailtyScore(double score) async {
    try {
      // PUT request to update frailty score
      final response = await http.put(
        Uri.parse(
          UserProvider.instance?.isEmailSignedIn == true
              ? AppConfig.profileEmailUrl
              : AppConfig.profileGoogleUrl,
        ),
        headers: BackendAuth().getAuthHeaders(),
        body: jsonEncode({'frailtyScore': score}),
      );

      if (response.statusCode == 200) {
        debugPrint('Frailty score updated successfully: $score');
        return true;
      } else {
        debugPrint('Failed to update frailty score: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating frailty score: $e');
      return false;
    }
  }
}
