import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:livewell_app/auth/tracking_auth.dart';
import 'package:livewell_app/shared/shared_preferences_provider.dart';
import 'package:livewell_app/shared/shared.dart';

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

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: onNotificationResponse,
      );

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
    await androidImplementation?.createNotificationChannel(
      recommendationsChannel,
    );
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

  static Future<void> showCustomRecommendationNotification({
    required String title,
    String? body,
    String? type,
    int? stepsTarget,
    int? waterIntakeTarget,
  }) async {
    // Build notification body
    String fullBody = '';

    // Append targets to existing body if present
    if (stepsTarget != null && stepsTarget > 0) {
      fullBody += '🚶 Steps: $stepsTarget';
    }
    if (waterIntakeTarget != null && waterIntakeTarget > 0) {
      fullBody += '\n💧 Water Intake: $waterIntakeTarget ml';
    }

    final androidDetails = AndroidNotificationDetails(
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
      styleInformation: BigTextStyleInformation(fullBody),
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'set_goal_action',
          'Set Goal',
          showsUserInterface: false,
          titleColor: Shared.orange,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Create payload
    final payload = jsonEncode({
      'steps': stepsTarget ?? 0,
      'water': waterIntakeTarget ?? 0,
    });

    await _notificationsPlugin.show(
      _recommendationsNotificationId,
      title,
      fullBody,
      notificationDetails,
      payload: payload,
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
  ) async {}
}

// Handle notification response (action buttons) - Top level function
@pragma('vm:entry-point')
Future<void> onNotificationResponse(NotificationResponse response) async {
  // Check if app is in foreground
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final isForeground = binding.lifecycleState == AppLifecycleState.resumed;
  debugPrint('Notification response received. Is Foreground: $isForeground');

  try {
    if (response.actionId == 'set_goal_action' && response.payload != null) {
      // Ensure shared preferences are initialized for auth headers
      await SharedPreferencesProvider.getBackgroundPrefs();

      final data = jsonDecode(response.payload!);
      final steps = data['steps'];
      final water = data['water'];

      // Update tracking targets
      if (steps is int && water is int) {
        await TrackingAuth.putTodayTrackingTargets(
          steps,
          water,
          isBackground: !isForeground,
        );
      } else {
        debugPrint(
          'Invalid payload types: steps=${steps.runtimeType}, water=${water.runtimeType}',
        );
      }
    } else {
      debugPrint('Action ID did not match or payload was null');
    }
  } catch (e, stackTrace) {
    debugPrint('CRITICAL ERROR in notification handler: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}
