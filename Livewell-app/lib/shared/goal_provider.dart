import 'package:flutter/material.dart';
import 'package:livewell_app/auth/tracking_auth.dart';
import 'package:livewell_app/services/background_service_manager.dart';
import 'package:livewell_app/services/notifications_service.dart';
import 'package:livewell_app/shared/shared_preferences_provider.dart';

class WaterIntakeNotifier extends ChangeNotifier {
  int _waterIntake = 2000;
  int _selected = 30;

  int get waterIntake => _waterIntake;
  int get selected => _selected;

  void setWaterIntake(int value) async {
    _waterIntake = value;
    _selected = ((_waterIntake - 500) / 50).round();

    final trackingData = await TrackingAuth.getTrackingToday();

    // Update the target water intake in the database
    TrackingAuth.putTodayTrackingTargets(
      trackingData!['target_steps'],
      _waterIntake,
    );

    notifyListeners();
  }

  void syncWaterIntake(int value) {
    _waterIntake = value;
    _selected = ((_waterIntake - 500) / 50).round();
    notifyListeners();
  }

  void setSelected(int value) {
    _selected = value;
  }
}

class CurrentWaterIntakeNotifier extends ChangeNotifier {
  int _currentWaterIntake = 0;
  final WaterIntakeNotifier _waterIntakeNotifier;
  bool _isInitialized = false;

  static CurrentWaterIntakeNotifier? instance;

  CurrentWaterIntakeNotifier(this._waterIntakeNotifier) {
    instance = this;
    _initializeFromStorage();
  }

  // Add this method to initialize from SharedPreferences
  void _initializeFromStorage() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      final storedWaterIntake = prefs?.getInt('current_water_intake') ?? 0;
      _currentWaterIntake = storedWaterIntake;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading stored water intake: $e');
      _isInitialized = true;
    }
  }

  int get currentWaterIntake => _currentWaterIntake;

  void setWaterIntake(int steps, int value) {
    _currentWaterIntake = value;
    TrackingAuth.putTodayTracking(steps, value);

    // Sent notification when water intake goal is reached
    if (value == _waterIntakeNotifier.waterIntake) {
      NotificationService.showWaterIntakeSyncNotification(value);
    }

    // Update current water intake in SharedPreferences as well
    BackgroundServiceManager.updateStoredWaterIntake(value);

    notifyListeners();
  }

  // Add this new method
  void updateFromTrackingData(Map<String, dynamic> trackingData) {
    _waterIntakeNotifier.syncWaterIntake(
      trackingData['target_water_intake_ml'],
    );
    _currentWaterIntake = trackingData['current_water_intake_ml'];

    notifyListeners();
  }

  Future<void> fetchAndSync() async {
    try {
      final trackingData = await TrackingAuth.getTrackingToday();
      if (trackingData != null) {
        updateFromTrackingData(trackingData);
      }
    } catch (e) {
      debugPrint('Error fetching tracking data: $e');
    }
  }

  void add250ml(int steps) {
    // Avoid exceeding the water intake
    if (_currentWaterIntake + 250 > _waterIntakeNotifier.waterIntake) {
      _currentWaterIntake = _waterIntakeNotifier.waterIntake;
    } else {
      _currentWaterIntake += 250;
    }

    setWaterIntake(steps, _currentWaterIntake);

    notifyListeners();
  }

  void add500ml(int steps) {
    // Avoid exceeding the water intake
    if (_currentWaterIntake + 500 > _waterIntakeNotifier.waterIntake) {
      _currentWaterIntake = _waterIntakeNotifier.waterIntake;
    } else {
      _currentWaterIntake += 500;
    }

    setWaterIntake(steps, _currentWaterIntake);

    notifyListeners();
  }
}

class StepsNotifier extends ChangeNotifier {
  int _steps = 6000;
  int _selected = 40;

  int get steps => _steps;
  int get selected => _selected;

  void setSteps(int value) async {
    _steps = value;
    _selected = ((value - 2000) / 100).round();
    debugPrint('Update Steps data');

    final trackingData = await TrackingAuth.getTrackingToday();

    debugPrint('Update Tracking data');
    // Update the target steps in the database
    TrackingAuth.putTodayTrackingTargets(
      _steps,
      trackingData!['target_water_intake_ml'],
    );

    notifyListeners();
  }

  void syncSteps(int value) {
    _steps = value;
    _selected = ((value - 2000) / 100).round();
    notifyListeners();
  }

  void setSelected(int value) {
    _selected = value;
  }
}

class CurrentStepsNotifier extends ChangeNotifier {
  int _currentSteps = 0;
  final StepsNotifier _stepsNotifier;

  static CurrentStepsNotifier? instance;

  CurrentStepsNotifier(this._stepsNotifier) {
    instance = this;
  }

  int get currentSteps => _currentSteps;

  void setCurrentSteps(int steps, int waterIntake) {
    _currentSteps = steps;
    TrackingAuth.putTodayTracking(steps, waterIntake);

    notifyListeners();
  }

  void updateFromTrackingData(Map<String, dynamic> trackingData) {
    _stepsNotifier.syncSteps(trackingData['target_steps']);
    _currentSteps = trackingData['current_steps'];

    notifyListeners();
  }

  Future<void> fetchAndSync() async {
    try {
      final trackingData = await TrackingAuth.getTrackingToday();
      if (trackingData != null) {
        updateFromTrackingData(trackingData);
      }
    } catch (e) {
      debugPrint('Error fetching steps data: $e');
    }
  }
}
