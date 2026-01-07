import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'env_config.dart';

void loadEnvironmentVariables() async {
  await dotenv.load(fileName: ".env");
}

class AppConfig {
  // Load environment variables
  loadEnvironmentVariables() {
    loadEnvironmentVariables();
  }

  // Backend server configuration
  static String backendUrl = EnvConfig.backendUrl;
  static String healthUrl = '$backendUrl/health';

  // Authentication endpoints
  static const String googleAuthEndpoint = '/auth/google';
  static const String facebookAuthEndpoint = '/auth/facebook';
  static const String logoutEndpoint = '/auth/logout';
  static const String chatbotEndpoint = '/chat';

  // Profile endpoints
  static const String profileEmailEndpoint = '/profile/email';
  static const String profileGoogleEndpoint = '/profile/google';

  // Tracking endpoints
  static const String trackingEmailEndpoint = '/tracking/email';
  static const String trackingGoogleEndpoint = '/tracking/google';
  static const String trackingTodayEmailEndpoint = '/tracking/today/email';
  static const String trackingTodayGoogleEndpoint = '/tracking/today/google';
  static const String trackingTodayTargetEmailEndpoint =
      '/tracking/today/targets/email';
  static const String trackingTodayTargetGoogleEndpoint =
      '/tracking/today/targets/google';

  // Health endpoints
  static const String medicationEndpoint = '/health/medications';
  static const String vaccineEndpoint = '/health/vaccinations';

  // Recommendation endpoints
  static const String suggestEndpoint = '/goals/suggested';
  static const String recommendationEndpoint = '/goals/suggested';

  // Local resources endpoints
  static const String localResourcesEndpoint = '/resources';

  // Notification endpoints
  static const String registerDeviceEmailEndpoint =
      '/fcm-noti/register-device/email';
  static const String registerDeviceGoogleEndpoint =
      '/fcm-noti/register-device/google';
  static const String unregisterDeviceEmailEndpoint =
      '/fcm-noti/unregister-device/email';
  static const String unregisterDeviceGoogleEndpoint =
      '/fcm-noti/unregister-device/google';

  // Get the full API URL
  static String get apiBaseUrl => '$backendUrl/api';

  // Get authentication endpoints
  static String get googleAuthUrl => '$apiBaseUrl$googleAuthEndpoint';
  static String get facebookAuthUrl => '$apiBaseUrl$facebookAuthEndpoint';
  static String get logoutUrl => '$apiBaseUrl$logoutEndpoint';
  static String get chatbotUrl => '$apiBaseUrl$chatbotEndpoint';
  static String get profileEmailUrl => '$apiBaseUrl$profileEmailEndpoint';
  static String get profileGoogleUrl => '$apiBaseUrl$profileGoogleEndpoint';
  static String get trackingEmailUrl => '$apiBaseUrl$trackingEmailEndpoint';
  static String get trackingGoogleUrl => '$apiBaseUrl$trackingGoogleEndpoint';
  static String get trackingTodayEmailUrl =>
      '$apiBaseUrl$trackingTodayEmailEndpoint';
  static String get trackingTodayGoogleUrl =>
      '$apiBaseUrl$trackingTodayGoogleEndpoint';
  static String get trackingTodayTargetEmailUrl =>
      '$apiBaseUrl$trackingTodayTargetEmailEndpoint';
  static String get trackingTodayTargetGoogleUrl =>
      '$apiBaseUrl$trackingTodayTargetGoogleEndpoint';

  // Get health endpoints
  static String get medicationUrl => '$apiBaseUrl$medicationEndpoint';
  static String get vaccineUrl => '$apiBaseUrl$vaccineEndpoint';

  // Get recommendation endpoints
  static String get suggestUrl => '$apiBaseUrl$suggestEndpoint';
  static String get recommendationUrl => '$apiBaseUrl$recommendationEndpoint';

  // Get local resources endpoints
  static String get localResourcesUrl => '$apiBaseUrl$localResourcesEndpoint';

  // Get notification endpoints
  static String get registerDeviceEmailUrl =>
      '$apiBaseUrl$registerDeviceEmailEndpoint';
  static String get registerDeviceGoogleUrl =>
      '$apiBaseUrl$registerDeviceGoogleEndpoint';
  static String get unregisterDeviceEmailUrl =>
      '$apiBaseUrl$unregisterDeviceEmailEndpoint';
  static String get unregisterDeviceGoogleUrl =>
      '$apiBaseUrl$unregisterDeviceGoogleEndpoint';
}
