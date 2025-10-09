class AppConfig {
  // Backend server configuration
  static const String backendUrl = 'https://livewell-backend.onrender.com';
  static const String healthUrl = '$backendUrl/health';

  // Authentication endpoints
  static const String googleAuthEndpoint = '/auth/google';
  static const String facebookAuthEndpoint = '/auth/facebook';
  static const String logoutEndpoint = '/auth/logout';
  static const String chatbotEndpoint = '/chat/';
  static const String profileEndpoint = '/profile/';
  static const String trackingEndpoint = '/tracking/';
  static const String trackingTodayEndpoint = '/tracking/today';
  static const String trackingTodayTargetEndpoint = '/tracking/today/targets';

  // Authorization Bearer Token
  static const String authorizationBearerToken =
      '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SEgV3p4LGOCSPX';

  // Get the full API URL
  static String get apiBaseUrl => '$backendUrl/api';

  // Get authentication endpoints
  static String get googleAuthUrl => '$apiBaseUrl$googleAuthEndpoint';
  static String get facebookAuthUrl => '$apiBaseUrl$facebookAuthEndpoint';
  static String get logoutUrl => '$apiBaseUrl$logoutEndpoint';
  static String get chatbotUrl => '$apiBaseUrl$chatbotEndpoint';
  static String get profileUrl => '$apiBaseUrl$profileEndpoint';
  static String get trackingUrl => '$apiBaseUrl$trackingEndpoint';
  static String get trackingTodayUrl => '$apiBaseUrl$trackingTodayEndpoint';
  static String get trackingTodayTargetUrl =>
      '$apiBaseUrl$trackingTodayTargetEndpoint';
}
