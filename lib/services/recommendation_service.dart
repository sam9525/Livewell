import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/recommendation_model.dart';
import '../config/app_config.dart';
import '../auth/backend_auth.dart';

// Service for AI health recommendations from backend
class RecommendationService {
  // Singleton pattern
  static final RecommendationService _instance =
      RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  // Fetch all recommendations
  Future<List<Recommendation>> getAllRecommendations() async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.suggestUrl),
        headers: BackendAuth().getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> recommendationsJson = json.decode(response.body);
        final recommendations = recommendationsJson
            .map((data) => Recommendation.fromMap(data))
            .toList();

        return recommendations;
      } else {
        debugPrint('Failed to fetch recommendations: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
      return [];
    }
  }

  // Fetch single recommendation
  Future<Recommendation?> getRecommendation(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.suggestUrl}/$id'),
        headers: BackendAuth().getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Recommendation.fromMap(data);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching recommendation: $e');
      return null;
    }
  }

  // Update recommendation (accept/apply)
  Future<bool> updateRecommendation(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      debugPrint('Updating recommendation $id with: $updates');

      final response = await http.put(
        Uri.parse('${AppConfig.suggestUrl}/$id'),
        headers: BackendAuth().getAuthHeaders(),
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        debugPrint('Recommendation $id updated successfully');
        return true;
      } else {
        debugPrint(
          'Failed to update recommendation $id: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error updating recommendation: $e');
      return false;
    }
  }

  // Accept/apply recommendation
  Future<bool> acceptRecommendation(String id) async {
    return updateRecommendation(id, {'isCompleted': true});
  }

  // Check if there are new recommendations (for notifications)
  Future<bool> hasNewRecommendations() async {
    try {
      final recommendations = await getAllRecommendations();
      // Check if there are any recommendations that haven't been set
      return recommendations.any((rec) => !rec.isCompleted);
    } catch (e) {
      debugPrint('Error checking for new recommendations: $e');
      return false;
    }
  }

  // Get count of new recommendations (for notification badge)
  Future<int> getNewRecommendationsCount() async {
    try {
      final recommendations = await getAllRecommendations();
      return recommendations.where((rec) => !rec.isCompleted).length;
    } catch (e) {
      debugPrint('Error getting new recommendations count: $e');
      return 0;
    }
  }
}
