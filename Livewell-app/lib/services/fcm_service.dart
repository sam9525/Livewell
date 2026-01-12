import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livewell_app/shared/user_provider.dart';
import '../config/app_config.dart';
import '../auth/backend_auth.dart';
import 'notifications_service.dart';

// Message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingHandler(RemoteMessage message) async {
  try {
    // Initialize notifications service for background isolate
    await NotificationService.initialize();

    // Extract data
    final data = message.data;
    final title = data['title'] ?? 'Notification';
    final body = data['body'];

    // Show the notification using our custom service which handles the actions
    await NotificationService.showCustomRecommendationNotification(
      title: title,
      body: body,
      type: data['type'],
      stepsTarget: int.tryParse(data['target_steps']?.toString() ?? '0') ?? 0,
      waterIntakeTarget:
          int.tryParse(data['target_water_intake_ml']?.toString() ?? '0') ?? 0,
    );
  } catch (e) {
    debugPrint('Error in background message handler: $e');
  }
}

// Firebase Cloud Messaging service for push notifications
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Singleton instance
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  // Initialize FCM and request notification permissions
  static Future<void> initialize() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      debugPrint('FCM permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Register device token with backend
        await registerCurrentDevice();

        FirebaseMessaging.onMessage.listen(_firebaseMessagingHandler);

        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingHandler);

        // Handle notification taps when app is in background or terminated
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Check if app was opened from a terminated state via notification
        RemoteMessage? initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          debugPrint('FCM token refreshed: $newToken');
          registerCurrentDevice();
        });
      } else {
        debugPrint('Notification permission denied');
      }
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  /// Get FCM device token
  static Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken();
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Helper to get token and register it
  static Future<void> registerCurrentDevice() async {
    String? token = await getToken();
    if (token != null) {
      await registerDeviceToken(token);
    }
  }

  // Register device token with backend API
  static Future<bool> registerDeviceToken(String token) async {
    try {
      // Get JWT token for authentication
      String? jwtToken = await BackendAuth.getStoredJwtToken();
      debugPrint('JWT token: $jwtToken');

      if (jwtToken == null) {
        debugPrint('No JWT token available for device registration');
        return false;
      }

      // Prepare request
      final url = Uri.parse(
        UserProvider.instance?.isEmailSignedIn == true
            ? AppConfig.registerDeviceEmailUrl
            : AppConfig.registerDeviceGoogleUrl,
      );
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };
      final body = json.encode({
        'device_token': token,
        'platform': 'mobile', // You can make this dynamic based on Platform
      });

      debugPrint('Registering device token with: $url');

      // Send POST request
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Failed to register device token: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error registering device token: $e');
      return false;
    }
  }

  // Handle notification tap (when user taps notification)
  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    debugPrint('Notification data: ${message.data}');
  }

  // Delete FCM token (useful for logout)
  static Future<void> deleteToken() async {
    try {
      await unregisterDeviceToken();

      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  // Unregister device token with backend API
  static Future<bool> unregisterDeviceToken() async {
    try {
      // Get JWT token for authentication
      String? jwtToken = await BackendAuth.getStoredJwtToken();
      debugPrint('JWT token: $jwtToken');

      if (jwtToken == null) {
        debugPrint('No JWT token available for device registration');
        return false;
      }

      // Prepare request
      final url = Uri.parse(
        UserProvider.instance?.isEmailSignedIn == true
            ? AppConfig.unregisterDeviceEmailUrl
            : AppConfig.unregisterDeviceGoogleUrl,
      );

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };

      debugPrint('Unregistering device token with: $url');

      // Send POST request
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Failed to unregister device token: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error unregistering device token: $e');
      return false;
    }
  }
}
