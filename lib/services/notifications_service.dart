import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

/// Consolidated notification service that handles all notification functionality
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification channel constants
  static const String _stepCounterChannelId = "step_counter_channel";
  static const String _updateStepsChannelId = "update_steps_channel";
  static const String _stepCounterChannelName = "Step Counter";
  static const String _updateStepsChannelName = "Update Steps";
  static const String _waterIntakeChannelId = "water_intake_channel";
  static const String _waterIntakeChannelName = "Water Intake";
  static const String _recommendationsChannelId = "recommendations_channel";
  static const String _recommendationsChannelName = "Health Recommendations";

  // Notification IDs
  static const int _stepCounterNotificationId = 888;
  static const int _stepsSyncNotificationId = 999;
  static const int _waterIntakeSyncNotificationId = 1000;
  static const int _recommendationsNotificationId = 1001;

  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initialize the notification service
  static Future<void> initialize() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(initSettings);

      // Create notification channels for Android
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  // Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    const stepCounterChannel = AndroidNotificationChannel(
      _stepCounterChannelId,
      _stepCounterChannelName,
      description: 'Keeps step counter running in background',
      importance: Importance.low,
      showBadge: false,
    );

    const updateStepsChannel = AndroidNotificationChannel(
      _updateStepsChannelId,
      _updateStepsChannelName,
      description: 'Update steps in background',
      importance: Importance.low,
      showBadge: false,
    );

    const waterIntakeChannel = AndroidNotificationChannel(
      _waterIntakeChannelId,
      _waterIntakeChannelName,
      description: 'Update water intake in background',
      importance: Importance.low,
      showBadge: false,
    );

    const recommendationsChannel = AndroidNotificationChannel(
      _recommendationsChannelId,
      _recommendationsChannelName,
      description: 'AI health recommendations',
      importance: Importance.high,
      showBadge: true,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.createNotificationChannel(stepCounterChannel);
    await androidImplementation?.createNotificationChannel(updateStepsChannel);
    await androidImplementation?.createNotificationChannel(waterIntakeChannel);
    await androidImplementation?.createNotificationChannel(recommendationsChannel);
  }

  // Show persistent notification for background step counting
  static Future<void> showPersistentNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _stepCounterChannelId,
      _stepCounterChannelName,
      channelDescription: 'Keeps step counter running in background',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      silent: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      _stepCounterNotificationId,
      'Step Counter',
      'Tracking your steps in the background',
      notificationDetails,
    );
  }

  // Show notification when steps are synced to database
  static Future<void> showStepsSyncNotification(int steps) async {
    const androidDetails = AndroidNotificationDetails(
      _updateStepsChannelId,
      _updateStepsChannelName,
      channelDescription: 'Update steps in background',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: false,
      autoCancel: true,
      showWhen: true,
      silent: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      _stepsSyncNotificationId,
      'Steps Updated',
      'Synced $steps steps to database',
      notificationDetails,
    );
  }

  // Show notification when steps are synced to database
  static Future<void> showWaterIntakeSyncNotification(int waterIntake) async {
    const androidDetails = AndroidNotificationDetails(
      _waterIntakeChannelId,
      _waterIntakeChannelName,
      channelDescription: 'Water Intake Reached',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: false,
      autoCancel: true,
      showWhen: true,
      silent: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      _waterIntakeSyncNotificationId,
      'Congratulations!',
      'You have reached your today\'s water intake goal of $waterIntake ml. Keep it up!',
      notificationDetails,
    );
  }

  // Show notification for new AI health recommendations
  static Future<void> showRecommendationsNotification({
    required int recommendedSteps,
    required int recommendedWaterMl,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _recommendationsChannelId,
      _recommendationsChannelName,
      channelDescription: 'AI health recommendations',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
      showWhen: true,
      silent: false,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      _recommendationsNotificationId,
      'New Health Recommendations',
      'AI suggests: $recommendedSteps steps and $recommendedWaterMl ml water daily',
      notificationDetails,
    );
  }

  // Show notification with custom title and message for recommendations
  static Future<void> showCustomRecommendationNotification({
    required String title,
    required String message,
    int? stepsTarget,
    int? waterIntakeTarget,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _recommendationsChannelId,
      _recommendationsChannelName,
      channelDescription: 'AI health recommendations',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
      showWhen: true,
      silent: false,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Build notification body
    String body = message;
    if (stepsTarget != null && stepsTarget > 0) {
      body += '\n🚶 Steps: $stepsTarget';
    }
    if (waterIntakeTarget != null && waterIntakeTarget > 0) {
      body += '\n💧 Water: $waterIntakeTarget ml';
    }

    await _notificationsPlugin.show(
      _recommendationsNotificationId,
      title,
      body,
      notificationDetails,
    );
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Get the notification plugin instance (for external use if needed)
  static FlutterLocalNotificationsPlugin get plugin => _notificationsPlugin;

  // Get notification channel IDs (for external use if needed)
  static String get stepCounterChannelId => _stepCounterChannelId;
  static String get updateStepsChannelId => _updateStepsChannelId;
  static String get waterIntakeChannelId => _waterIntakeChannelId;
  static int get stepCounterNotificationId => _stepCounterNotificationId;
  static int get stepsSyncNotificationId => _stepsSyncNotificationId;
}

// Legacy class for backward compatibility
@Deprecated('Use NotificationService instead')
class Notifications {
  @Deprecated('Use NotificationService.initialize() instead')
  static Future<void> initializeNotifications(
    String notificationChannelId,
    String notificationChannelName,
    int notificationId,
    FlutterLocalNotificationsPlugin notificationsPlugin,
  ) async {
    await NotificationService.initialize();
  }
}
