import 'package:flutter/material.dart';
import 'package:livewell_app/auth/tracking_auth.dart';
import 'package:livewell_app/shared/shared.dart';

class DateProvider extends ChangeNotifier {
  DateTime now = DateTime.now();
  late String startOfWeek;
  late String endOfWeek = now.toIso8601String().split("T").first;
  int currentWeekIndex = 0;

  List<String> weeklyNames = [];
  bool isLoading = false;
  List<List<double>> weeklySteps = [];

  bool hasPreviousWeek = false;

  // Constructor to initialize the provider
  DateProvider() {
    weeklySteps.clear();
    _initializeData();
  }

  void _initializeData() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    await getWeeklySteps();
    generateWeeklyNames();

    isLoading = false;
    notifyListeners();
  }

  Future<void> getWeeklySteps() async {
    final currentWeekBounds = _calculateWeekBounds(endOfWeek);
    startOfWeek = currentWeekBounds.start;

    await _loadWeekData(startOfWeek, endOfWeek);

    await _checkPreviousWeekData();
  }

  // Return the start and end of the week
  ({String start, String end}) _calculateWeekBounds(String date) {
    final daysFromSunday = DateTime.parse(date).weekday == DateTime.sunday
        ? 0
        : DateTime.parse(date).weekday;
    final weekStart = DateTime.parse(
      date,
    ).subtract(Duration(days: daysFromSunday));
    final weekEnd = daysFromSunday == 0
        ? weekStart.add(Duration(days: 6))
        : DateTime.parse(date);

    return (
      start: weekStart.toIso8601String().split('T').first,
      end: weekEnd.toIso8601String().split('T').first,
    );
  }

  // Load the week data from the tracking data
  Future<void> _loadWeekData(String startDate, String endDate) async {
    try {
      final trackingData = await TrackingAuth.getTracking(startDate, endDate);
      final currentWeeklySteps = _extractWeeklySteps(
        trackingData,
        startDate,
        endDate,
      );

      if (currentWeeklySteps.isNotEmpty) {
        weeklySteps.add(currentWeeklySteps);
      }
    } catch (e) {
      debugPrint('Error loading week data: $e');
      // Add empty week data to maintain consistency
      weeklySteps.add(List.filled(7, 0.0));
    }
  }

  // Extract the weekly steps from the tracking data
  List<double> _extractWeeklySteps(
    Map<String, dynamic>? trackingData,
    String startDate,
    String endDate,
  ) {
    final logs = trackingData?['logs'] as List<dynamic>? ?? [];

    // Create lookup map for O(1) access
    final logMap = <String, double>{
      for (final log in logs)
        if (log['logDate'] != null)
          log['logDate']: (log['currentSteps'] ?? 0) / 1000,
    };

    // Generate steps for each day in the week
    final weeklySteps = <double>[];
    DateTime currentDate = DateTime.parse(startDate);
    final endDateTime = DateTime.parse(endDate);

    while (!currentDate.isAfter(endDateTime)) {
      final dateStr = currentDate.toIso8601String().split('T').first;
      weeklySteps.add(logMap[dateStr] ?? 0.0);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return weeklySteps;
  }

  // Check if the previous week data is available
  Future<void> _checkPreviousWeekData() async {
    try {
      final previousWeekBounds = _calculateWeekBounds(
        DateTime.parse(
          startOfWeek,
        ).subtract(const Duration(days: 7)).toIso8601String().split("T").first,
      );

      final previousWeekData = await TrackingAuth.getTracking(
        previousWeekBounds.start,
        previousWeekBounds.end,
      );

      final hasData = previousWeekData?['logs']?.isNotEmpty == true;
      hasPreviousWeek = hasData;

      if (hasData) {
        startOfWeek = previousWeekBounds.start;
        endOfWeek = previousWeekBounds.end;
      }
    } catch (e) {
      debugPrint('Error checking previous week data: $e');
      hasPreviousWeek = false;
    }
  }

  static String _monthAbbr(int month) => AppConstants.months[month - 1];

  void generateWeeklyNames() {
    // Clear existing names first
    weeklyNames.clear();

    // Generate week names based on the number of weeks in the user's data
    int weeksToGenerate = weeklySteps.isEmpty ? 1 : weeklySteps.length;

    // Generate week names based on the number of weeks in the user's data
    for (int i = 0; i < weeksToGenerate; i++) {
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
    // currentWeekIndex = 0;
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
    _initializeData();
    notifyListeners();
  }

  bool get canGoPrevious =>
      currentWeekIndex < weeklySteps.length - 1 || hasPreviousWeek;
  bool get canGoNext => currentWeekIndex > 0;
}
