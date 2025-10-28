import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:livewell_app/auth/tracking_auth.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:livewell_app/services/notifications_service.dart';
import 'package:livewell_app/shared/shared_preferences_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:livewell_app/firebase_options.dart';

// WorkManager callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('WorkManager task executed: $task');

    try {
      // Initialize Firebase for background context
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Update step count
      await _updateStepCount();

      // Sync to database
      await BackgroundServiceManager.syncToDatabase();

      return Future.value(true);
    } catch (e) {
      debugPrint('WorkManager task error: $e');
      return Future.value(false);
    }
  });
}

// Background service entry point
@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Initialize Firebase for background context
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferencesProvider.getBackgroundPrefs();

  // Show persistent notification
  await NotificationService.showPersistentNotification();

  // Show update steps notification
  await NotificationService.showStepsSyncNotification(
    prefs?.getInt('background_steps') ?? 0,
  );

  // Start step counting
  await _startStepCountingInService(service);
}

// iOS background handler
@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // Initialize Firebase for background context
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  return true;
}

class BackgroundServiceManager {
  static const String _taskName = "stepCounterTask";

  static Timer? _stepIncrementTimer;
  static StreamSubscription<int>? _pedometerSubscription;
  static Pedometer? _pedometer;

  // Initialize the background service system
  static Future<void> initialize() async {
    try {
      // Initialize notifications
      await NotificationService.initialize();

      // Initialize WorkManager
      await Workmanager().initialize(callbackDispatcher);

      // Initialize background service
      await _initializeBackgroundService();
    } catch (e) {
      debugPrint('Error initializing background service system: $e');
    }
  }

  // Initialize background service
  static Future<void> _initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: _onStart,
        isForegroundMode: true,
        autoStartOnBoot: true,
        notificationChannelId: NotificationService.stepCounterChannelId,
        initialNotificationTitle: 'Step Counter',
        initialNotificationContent: 'Tracking your steps in the background',
        foregroundServiceNotificationId:
            NotificationService.stepCounterNotificationId,
      ),
    );
  }

  // Start background step counting
  static Future<void> startStepCounting() async {
    try {
      // Check permissions first
      bool granted = await _checkPermissions();
      if (!granted) {
        debugPrint('Permissions not granted for background step counting');
        return;
      }

      // Start WorkManager task (more reliable for background)
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: const Duration(minutes: 1), // Check every 1 minute
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        initialDelay: const Duration(seconds: 10), // Start after 10 seconds
      );

      // Also start foreground service for immediate updates
      final service = FlutterBackgroundService();
      await service.startService();

      debugPrint('Background step counting started');
    } catch (e) {
      debugPrint('Error starting background step counting: $e');
    }
  }

  // Check required permissions
  static Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      // Check activity recognition permission
      bool granted = await Permission.activityRecognition.isGranted;
      if (!granted) {
        granted =
            await Permission.activityRecognition.request() ==
            PermissionStatus.granted;
      }

      // Request battery optimization exemption
      if (granted) {
        try {
          await Permission.ignoreBatteryOptimizations.request();
        } catch (e) {
          debugPrint('Battery optimization request failed: $e');
        }
      }

      return granted;
    }
    return true;
  }

  // Stop background step counting
  static Future<void> stopStepCounting() async {
    try {
      // Cancel the step increment timer
      _stepIncrementTimer?.cancel();
      _stepIncrementTimer = null;

      // Cancel pedometer subscription
      await _pedometerSubscription?.cancel();
      _pedometerSubscription = null;

      await Workmanager().cancelByUniqueName(_taskName);
      await Workmanager().cancelByUniqueName("${_taskName}_immediate");

      final service = FlutterBackgroundService();
      service.invoke('stop');

      debugPrint('Background step counting stopped');
    } catch (e) {
      debugPrint('Error stopping background step counting: $e');
    }
  }

  // Get current step count from background
  static Future<int> getCurrentStepCount() async {
    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      return prefs?.getInt('background_steps') ?? 0;
    } catch (e) {
      debugPrint('Error getting current step count: $e');
      return 0;
    }
  }

  // Update stored water intake for background sync
  static Future<void> updateStoredWaterIntake(int waterIntake) async {
    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      await prefs?.setInt('current_water_intake', waterIntake);
      debugPrint('Stored water intake updated: ${waterIntake}ml');
    } catch (e) {
      debugPrint('Error updating stored water intake: $e');
    }
  }

  // Consolidated database sync method
  static Future<bool> syncToDatabase() async {
    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      // Get current values from storage if not provided
      final currentSteps = prefs?.getInt('background_steps') ?? 0;
      final currentWaterIntake = prefs?.getInt('current_water_intake') ?? 0;

      // Attempt to sync to database
      final syncSuccess = await TrackingAuth.putTodayTrackingBackground(
        currentSteps,
        currentWaterIntake,
      );

      if (syncSuccess) {
        // Mark as synced
        await prefs?.setBool('needs_database_sync', false);
        await prefs?.setString(
          'last_database_sync',
          DateTime.now().toIso8601String(),
        );

        debugPrint('Database sync successful - Steps: $currentSteps');

        // Show notification
        await NotificationService.showStepsSyncNotification(currentSteps);

        return true;
      } else {
        debugPrint('Database sync failed - will retry later');
        // Queue for retry
        // await _queueFailedUpdate(currentSteps, currentWaterIntake);
        return false;
      }
    } catch (e) {
      debugPrint('Error in database sync: $e');
      // Don't rethrow the error to prevent breaking the step counter
      return false;
    }
  }

  // Queue failed update for retry when app comes back online
  static Future<void> _queueFailedUpdate(int steps, int waterIntake) async {
    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      final failedUpdates =
          prefs?.getStringList('failed_tracking_updates') ?? [];

      final updateData = {
        'steps': steps,
        'waterIntake': waterIntake,
        'timestamp': DateTime.now().toIso8601String(),
      };

      failedUpdates.add(jsonEncode(updateData));

      // Keep only the last 10 failed updates to prevent storage bloat
      if (failedUpdates.length > 10) {
        failedUpdates.removeAt(0);
      }

      await prefs?.setStringList('failed_tracking_updates', failedUpdates);
      debugPrint(
        'Queued failed update for retry: Steps: $steps, Water: ${waterIntake}ml',
      );
    } catch (e) {
      debugPrint('Error queuing failed update: $e');
    }
  }

  // Retry failed updates when app comes back online
  static Future<void> retryFailedUpdates() async {
    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      final failedUpdates =
          prefs?.getStringList('failed_tracking_updates') ?? [];

      if (failedUpdates.isEmpty) {
        debugPrint('No failed updates to retry');
        return;
      }

      debugPrint('Retrying ${failedUpdates.length} failed updates');

      for (String updateStr in failedUpdates) {
        try {
          final updateData = jsonDecode(updateStr);
          final steps = updateData['steps'] as int;
          final waterIntake = updateData['waterIntake'] as int;

          bool success = await TrackingAuth.putTodayTrackingBackground(
            steps,
            waterIntake,
          );
          if (success) {
            debugPrint(
              'Successfully retried update: Steps: $steps, Water: ${waterIntake}ml',
            );
          } else {
            debugPrint(
              'Retry failed for: Steps: $steps, Water: ${waterIntake}ml',
            );
          }
        } catch (e) {
          debugPrint('Error retrying individual update: $e');
        }
      }

      // Clear the failed updates list after retry attempt
      await prefs?.remove('failed_tracking_updates');
      debugPrint('Cleared failed updates queue');
    } catch (e) {
      debugPrint('Error retrying failed updates: $e');
    }
  }
}

// Start step counting in background service
Future<void> _startStepCountingInService(ServiceInstance service) async {
  try {
    // Cancel any existing timer and subscription
    BackgroundServiceManager._stepIncrementTimer?.cancel();
    await BackgroundServiceManager._pedometerSubscription?.cancel();

    // Initialize pedometer
    BackgroundServiceManager._pedometer = Pedometer();

    // Get today's step count from pedometer
    final todaySteps = await _getTodayStepsInBackground();

    // Store initial step count
    final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
    await prefs?.setInt('background_steps', todaySteps);
    await prefs?.setString(
      'last_step_update',
      DateTime.now().toIso8601String(),
    );

    // Set up periodic updates to get fresh step count
    BackgroundServiceManager._stepIncrementTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) async {
        try {
          final currentSteps = await _getTodayStepsInBackground();

          // Update stored step count
          await prefs?.setInt('background_steps', currentSteps);
          await prefs?.setString(
            'last_step_update',
            DateTime.now().toIso8601String(),
          );

          // Mark that we need to sync to database
          await prefs?.setBool('needs_database_sync', true);
        } catch (e) {
          debugPrint('Background service - Error updating pedometer steps: $e');
        }
      },
    );
  } catch (e) {
    debugPrint('Background step counting error: $e');
  }
}

// Get today's step count from pedometer in background service
Future<int> _getTodayStepsInBackground() async {
  try {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    int steps = await BackgroundServiceManager._pedometer!.getStepCount(
      from: startOfDay,
      to: endOfDay,
    );
    return steps;
  } catch (e) {
    debugPrint('Background service - Error getting today\'s steps: $e');
    return 0;
  }
}

// Update step count in background
Future<void> _updateStepCount() async {
  try {
    final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
    // Get current step count from pedometer if available
    if (BackgroundServiceManager._pedometer != null) {
      try {
        final todaySteps = await _getTodayStepsInBackground();
        await _updateStepsInBackground(todaySteps);

        await prefs?.setBool('needs_database_sync', true);

        // Also try immediate database sync
        await BackgroundServiceManager.syncToDatabase();

        debugPrint('WorkManager updated steps from pedometer: $todaySteps');
      } catch (e) {
        debugPrint('Error getting pedometer steps in WorkManager: $e');
        // Fallback to stored value

        int currentSteps = prefs?.getInt('background_steps') ?? 0;
        await _updateStepsInBackground(currentSteps);
        await prefs?.setBool('needs_database_sync', true);
        await BackgroundServiceManager.syncToDatabase();
      }
    } else {
      // Fallback to stored value if pedometer not available

      int currentSteps = prefs?.getInt('background_steps') ?? 0;
      await _updateStepsInBackground(currentSteps);
      await prefs?.setBool('needs_database_sync', true);
      await BackgroundServiceManager.syncToDatabase();
      debugPrint('WorkManager updated steps from storage: $currentSteps');
    }
  } catch (e) {
    debugPrint('Error updating step count in WorkManager: $e');
  }
}

// Update steps in SharedPreferences
Future<void> _updateStepsInBackground(int steps) async {
  try {
    final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
    await prefs?.setInt('background_steps', steps);
    await prefs?.setString(
      'last_step_update',
      DateTime.now().toIso8601String(),
    );
    debugPrint('Background steps updated: $steps');
  } catch (e) {
    debugPrint('Error updating background steps: $e');
  }
}
