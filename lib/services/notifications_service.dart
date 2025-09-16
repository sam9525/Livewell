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

  // Notification IDs
  static const int _stepCounterNotificationId = 888;
  static const int _stepsSyncNotificationId = 999;

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

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.createNotificationChannel(stepCounterChannel);
    await androidImplementation?.createNotificationChannel(updateStepsChannel);
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

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Get the notification plugin instance (for external use if needed)
  static FlutterLocalNotificationsPlugin get plugin => _notificationsPlugin;

  // Get notification channel IDs (for external use if needed)
  static String get stepCounterChannelId => _stepCounterChannelId;
  static String get updateStepsChannelId => _updateStepsChannelId;
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
