import 'package:flutter/material.dart';

class WaterIntakeNotifier extends ChangeNotifier {
  int _waterIntake = 2000;
  int _selected = 30;

  int get waterIntake => _waterIntake;
  int get selected => _selected;

  void setWaterIntake(int value) {
    _waterIntake = value;
    _selected = ((value - 500) / 50).round();
    notifyListeners();
  }
}

class CurrentWaterIntakeNotifier extends ChangeNotifier {
  int _currentWaterIntake = 0;
  final WaterIntakeNotifier _waterIntakeNotifier;

  CurrentWaterIntakeNotifier(this._waterIntakeNotifier);

  int get currentWaterIntake => _currentWaterIntake;

  void setWaterIntake(int value) {
    _currentWaterIntake = value;
    notifyListeners();
  }

  void add250ml() {
    // Avoid exceeding the water intake
    if (_currentWaterIntake + 250 > _waterIntakeNotifier.waterIntake) {
      _currentWaterIntake = _waterIntakeNotifier.waterIntake;
    } else {
      _currentWaterIntake += 250;
    }
    notifyListeners();
  }

  void add500ml() {
    // Avoid exceeding the water intake
    if (_currentWaterIntake + 500 > _waterIntakeNotifier.waterIntake) {
      _currentWaterIntake = _waterIntakeNotifier.waterIntake;
    } else {
      _currentWaterIntake += 500;
    }
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
