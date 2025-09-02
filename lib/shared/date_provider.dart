import 'package:flutter/material.dart';
import 'package:livewell_app/shared/shared.dart';

class DateProvider extends ChangeNotifier {
  DateTime now = DateTime.now().add(const Duration(hours: 9, minutes: 30));
  late DateTime startOfWeek;
  late DateTime endOfWeek;
  int currentWeekIndex = 0;

  List<String> weeklyNames = [];

  // Constructor to initialize the provider
  DateProvider() {
    generateWeeklyNames();
  }

  // Example : Weekly activity times for 4 weeks
  static final List<List<int>> _weeklyDataTimes = [
    [20, 60, 40, 40, 40, 20, 80],
    [40, 60, 100, 80, 20, 40, 40],
    [20, 40, 60, 80, 100, 80, 40],
    [100, 60, 40, 20, 40, 120, 80],
  ];

  List<List<int>> get weeklyDataTimes => _weeklyDataTimes;

  static String _monthAbbr(int month) => AppConstants.months[month - 1];

  void generateWeeklyNames() {
    // Clear existing names first
    weeklyNames.clear();

    // Generate week names based on the number of weeks in the user's data
    for (int i = 0; i < _weeklyDataTimes.length; i++) {
      DateTime weekStart = now.subtract(
        Duration(days: (now.weekday % 7) + (i * 7)),
      );
      DateTime weekEnd = weekStart.add(const Duration(days: 6));

      String startMonthAbbr = _monthAbbr(weekStart.month);
      String endMonthAbbr = _monthAbbr(weekEnd.month);

      String weekName = weekStart.month == weekEnd.month
          ? '${weekStart.day} $startMonthAbbr - ${weekEnd.day} $endMonthAbbr'
          : '${weekStart.day} $startMonthAbbr - ${weekEnd.day} $endMonthAbbr';

      weeklyNames.add(weekName);
    }

    // Set the current week index to the current week (index 0)
    currentWeekIndex = 0;
    notifyListeners();
  }

  void nextWeek() {
    if (!canGoNext) {
      return;
    }
    currentWeekIndex--;
    notifyListeners();
  }

  void previousWeek() {
    if (!canGoPrevious) {
      return;
    }
    currentWeekIndex++;
    notifyListeners();
  }

  bool get canGoPrevious => currentWeekIndex < weeklyDataTimes.length - 1;
  bool get canGoNext => currentWeekIndex > 0;
}
