import 'package:flutter/material.dart';
import 'package:livewell_app/auth/tracking_auth.dart';
import 'package:livewell_app/services/background_service_manager.dart';
import 'package:livewell_app/shared/shared_preferences_provider.dart';

class WaterIntakeNotifier extends ChangeNotifier {
  int _waterIntake = 2000;
  int _selected = 30;

  int get waterIntake => _waterIntake;
  int get selected => _selected;

  void setWaterIntake(int value) async {
    final trackingData = await TrackingAuth.getTrackingToday();
    if (trackingData != null) {
      _waterIntake = trackingData['targetWaterIntakeMl'];
      _selected = ((_waterIntake - 500) / 50).round();
    }
    notifyListeners();
  }
}

class CurrentWaterIntakeNotifier extends ChangeNotifier {
  int _currentWaterIntake = 0;
  final WaterIntakeNotifier _waterIntakeNotifier;
  bool _isInitialized = false;

  CurrentWaterIntakeNotifier(this._waterIntakeNotifier) {
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

    // Update current water intake in SharedPreferences as well
    BackgroundServiceManager.updateStoredWaterIntake(value);

    notifyListeners();
  }

  // Add this new method
  void updateFromTrackingData(Map<String, dynamic> trackingData) {
    _waterIntakeNotifier.setWaterIntake(trackingData['targetWaterIntakeMl']);
    _currentWaterIntake = trackingData['currentWaterIntakeMl'];

    notifyListeners();
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

  void setSteps(int value) {
    _steps = value;
    _selected = ((value - 2000) / 100).round();
    notifyListeners();
  }
}

class CurrentStepsNotifier extends ChangeNotifier {
  int _currentSteps = 0;
  final StepsNotifier _stepsNotifier;

  CurrentStepsNotifier(this._stepsNotifier);

  int get currentSteps => _currentSteps;

  void setCurrentSteps(int steps, int waterIntake) {
    _currentSteps = steps;
    TrackingAuth.putTodayTracking(steps, waterIntake);

    notifyListeners();
  }

  void updateFromTrackingData(Map<String, dynamic> trackingData) {
    _stepsNotifier.setSteps(trackingData['targetSteps']);
    _currentSteps = trackingData['currentSteps'];

    notifyListeners();
  }
}
