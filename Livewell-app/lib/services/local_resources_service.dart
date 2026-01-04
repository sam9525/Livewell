import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../auth/backend_auth.dart';
import '../model/local_resource_model.dart';

// Service for local resources from backend
class LocalResourcesService {
  // Singleton pattern
  static final LocalResourcesService _instance =
      LocalResourcesService._internal();
  factory LocalResourcesService() => _instance;
  LocalResourcesService._internal();

  // Fetch local resources by postcode
  Future<List<LocalResource>> getResourcesByPostcode(String postcode) async {
    try {
      // Remove spaces and validate postcode
      final cleanPostcode = postcode.replaceAll(' ', '');
      if (cleanPostcode.isEmpty ||
          cleanPostcode == 'Unknown' ||
          cleanPostcode.contains('available')) {
        debugPrint('Invalid postcode: $postcode');
        return [];
      }

      debugPrint('Fetching local resources for postcode: $cleanPostcode');
      debugPrint(
        'API URL: ${AppConfig.localResourcesUrl}?postcode=$cleanPostcode',
      );

      final response = await http.get(
        Uri.parse('${AppConfig.localResourcesUrl}?postcode=$cleanPostcode'),
        headers: BackendAuth().getAuthHeaders(),
      );

      debugPrint('Local resources API response status: ${response.statusCode}');
      debugPrint('Local resources API response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> resourcesJson = json.decode(response.body);
        debugPrint('Local resources JSON parsed: $resourcesJson');
        final resources = resourcesJson
            .map((data) => LocalResource.fromMap(data))
            .toList();

        debugPrint('Found ${resources.length} local resources');
        return resources;
      } else {
        debugPrint('Failed to fetch local resources: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching local resources: $e');
      return [];
    }
  }
}
