import 'package:flutter/material.dart';
import '../../shared/goal_provider.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class WeeklyName extends StatelessWidget {
  final List<String> weeklyNames;
  final int currentWeekIndex;
  final bool canGoPrevious;
  final bool canGoNext;
  final void Function() previousWeek;
  final void Function() nextWeek;

  const WeeklyName({
    super.key,
    required this.weeklyNames,
    required this.currentWeekIndex,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.previousWeek,
    required this.nextWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: canGoPrevious ? previousWeek : null,
              icon: const Icon(Icons.navigate_before_rounded, size: 32),
            ),
          ),
        ),
        SizedBox(
          child: Text(
            weeklyNames.isNotEmpty && currentWeekIndex < weeklyNames.length
                ? weeklyNames[currentWeekIndex]
                : "No data",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Shared.orange,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: canGoNext ? nextWeek : null,
              icon: const Icon(Icons.navigate_next_rounded, size: 32),
            ),
          ),
        ),
      ],
    );
  }
}

class BuildLineChart extends StatelessWidget {
  final List<List<double>> weeklySteps;
  final int weekIndex;
  final List<String> weekDays;

  const BuildLineChart({
    super.key,
    required this.weeklySteps,
    required this.weekIndex,
    required this.weekDays,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 8,
          lineBarsData: [
            LineChartBarData(
              color: Shared.orange,
              spots: weeklySteps[weekIndex].isNotEmpty
                  ? List.generate(
                      weeklySteps[weekIndex].length,
                      (i) => FlSpot(
                        i.toDouble(),
                        weeklySteps[weekIndex][i].toDouble(),
                      ),
                    )
                  : [],
              isCurved: true,
              shadow: const Shadow(color: Shared.orange),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final touchedSpots = barData.showingIndicators ?? [];
                  final isTouched = touchedSpots.contains(index);
                  return FlDotCirclePainter(
                    radius: isTouched ? 9 : 6,
                    color: isTouched ? Colors.white : Shared.orange,
                    strokeWidth: isTouched ? 4 : 2,
                    strokeColor: isTouched ? Shared.orange : Colors.white,
                  );
                },
              ),

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Shared.orange.withValues(alpha: 0.2),
                    Shared.orange.withValues(alpha: 0.05),
                  ],
                  stops: const [0.5, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Shared.orange,
              getTooltipItems: (touchedSpots) {
                return [
                  LineTooltipItem(
                    "${(touchedSpots.first.y * 1000).toInt()}",
                    Shared.fontStyle(20, FontWeight.w500, Colors.white),
                  ),
                ];
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                interval: 2,
                showTitles: true,
                reservedSize: 40,
                maxIncluded: true,
                getTitlesWidget: leftTitleWidgets,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: bottomTitleWidgets,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (value % 1 != 0) {
      return Container();
    }

    int index = value.toInt();
    if (index < 0 || index >= weekDays.length) {
      return Container();
    }

    return SideTitleWidget(
      space: 6,
      meta: meta,
      fitInside: SideTitleFitInsideData.disable(),
      child: Text(
        weekDays[index],
        style: Shared.fontStyle(24, FontWeight.w500, Shared.black),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    if (value % 1 != 0) {
      return Container();
    }

    return SideTitleWidget(
      space: 6,
      meta: meta,
      fitInside: SideTitleFitInsideData.disable(),
      child: Text(
        (() {
          switch (value.toInt()) {
            case 2:
              return '2K';
            case 4:
              return '4k';
            case 6:
              return '6K';
            case 8:
              return '8K';
            default:
              return '';
          }
        })(),
        style: Shared.fontStyle(24, FontWeight.w500, Shared.black),
      ),
    );
  }
}

class WaterIntakeSliders extends StatelessWidget {
  const WaterIntakeSliders({super.key});

  static double buttonWidth(BuildContext context) =>
      ((MediaQuery.of(context).size.width - 40) / 2) - 30;

  @override
  Widget build(BuildContext context) {
    return Consumer3<
      WaterIntakeNotifier,
      CurrentWaterIntakeNotifier,
      CurrentStepsNotifier
    >(
      builder:
          (
            context,
            waterIntakeNotifier,
            currentWaterIntakeNotifier,
            currentStepsNotifier,
            child,
          ) {
            return Column(
              children: [
                Text(
                  "Water Intake: ${currentWaterIntakeNotifier.currentWaterIntake} ml",
                  style: Shared.fontStyle(28, FontWeight.w500, Shared.black),
                ),
                _sliderTheme(
                  context,
                  currentWaterIntakeNotifier,
                  waterIntakeNotifier,
                  currentStepsNotifier,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "0",
                      style: Shared.fontStyle(
                        24,
                        FontWeight.w500,
                        Shared.black,
                      ),
                    ),
                    Text(
                      waterIntakeNotifier.waterIntake.toString(),
                      style: Shared.fontStyle(
                        24,
                        FontWeight.w500,
                        Shared.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _addWaterButton(
                      context,
                      currentWaterIntakeNotifier,
                      currentStepsNotifier,
                      "+250 ml",
                    ),
                    SizedBox(width: 30),
                    _addWaterButton(
                      context,
                      currentWaterIntakeNotifier,
                      currentStepsNotifier,
                      "+500 ml",
                    ),
                  ],
                ),
              ],
            );
          },
    );
  }

  Widget _sliderTheme(
    BuildContext context,
    CurrentWaterIntakeNotifier currentWaterIntakeNotifier,
    WaterIntakeNotifier waterIntakeNotifier,
    CurrentStepsNotifier currentStepsNotifier,
  ) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Shared.orange,
        inactiveTrackColor: Shared.lightGray,
        trackHeight: 12.0,
        thumbColor: Shared.orange,
        overlayColor: Shared.orange.withValues(alpha: 0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
        valueIndicatorColor: Shared.orange,
        valueIndicatorTextStyle: Shared.fontStyle(
          18,
          FontWeight.bold,
          Colors.white,
        ),
      ),
      child: Slider(
        value: currentWaterIntakeNotifier.currentWaterIntake.toDouble(),
        max: waterIntakeNotifier.waterIntake.toDouble(),
        divisions: (waterIntakeNotifier.waterIntake / 50).toInt(),
        label: "${currentWaterIntakeNotifier.currentWaterIntake}",
        onChanged: (double value) {
          currentWaterIntakeNotifier.setWaterIntake(
            currentStepsNotifier.currentSteps,
            value.toInt(),
          );
        },
      ),
    );
  }

  Widget _addWaterButton(
    BuildContext context,
    CurrentWaterIntakeNotifier currentWaterIntakeNotifier,
    CurrentStepsNotifier currentStepsNotifier,
    String text,
  ) {
    return ElevatedButton(
      onPressed: () {
        if (text == "+250 ml") {
          currentWaterIntakeNotifier.add250ml(
            currentStepsNotifier.currentSteps,
          );
        } else if (text == "+500 ml") {
          currentWaterIntakeNotifier.add500ml(
            currentStepsNotifier.currentSteps,
          );
        }
      },
      style: Shared.buttonStyle(
        buttonWidth(context),
        52,
        Colors.white,
        Shared.orange,
      ),
      child: Text(
        text,
        style: Shared.fontStyle(24, FontWeight.bold, Shared.orange),
      ),
    );
  }
}

class StepsWidget extends StatefulWidget {
  const StepsWidget({super.key});

  @override
  State<StepsWidget> createState() => _StepsWidgetState();
}

class _StepsWidgetState extends State<StepsWidget> {
  late Stream<StepCount> _stepCountStream;
  bool _isInitialized = false;
  String _lastResetDate = '';

  int offset = 0;

  @override
  void initState() {
    super.initState();
    _lastResetDate = _getCurrentDate();
    initPlatformState();
    _startDailyCheck();
  }

  String _getCurrentDate() {
    return DateTime.now().toIso8601String().split('T').first;
  }

  void _startDailyCheck() {
    // Check every minute if we need to reset
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndResetIfNewDay();
    });
  }

  void _checkAndResetIfNewDay() {
    final currentDate = _getCurrentDate();
    if (currentDate != _lastResetDate) {
      _resetStepsForNewDay();
      _lastResetDate = currentDate;
    }
  }

  void _resetStepsForNewDay() {
    if (mounted) {
      // Reset step count to 0
      final currentStepsNotifier = context.read<CurrentStepsNotifier>();
      final currentWaterIntakeNotifier = context
          .read<CurrentWaterIntakeNotifier>();

      _resetStepsForNewSession(currentStepsNotifier.currentSteps);

      currentStepsNotifier.setCurrentSteps(0, 0);
      currentWaterIntakeNotifier.setWaterIntake(0, 0);

      debugPrint('Steps reset for new day: $_lastResetDate');
    }
  }

  void _resetStepsForNewSession(int currentSensorValue) {
    if (mounted) {
      offset = currentSensorValue;
    }
  }

  void onStepCount(StepCount event) {
    if (mounted) {
      final currentStepsNotifier = context.read<CurrentStepsNotifier>();
      final currentWaterIntakeNotifier = context
          .read<CurrentWaterIntakeNotifier>();

      currentStepsNotifier.setCurrentSteps(
        event.steps - offset,
        currentWaterIntakeNotifier.currentWaterIntake,
      );
    }
  }

  void onStepCountError(error) {
    debugPrint('onStepCountError: $error');
  }

  Future<void> initPlatformState() async {
    try {
      bool granted = await _checkActivityRecognitionPermission();
      if (!granted) {
        return;
      }

      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(onStepCount).onError(onStepCountError);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Failed to initialize pedometer: $e');
    }
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    bool granted = await Permission.activityRecognition.isGranted;

    if (!granted) {
      granted =
          await Permission.activityRecognition.request() ==
          PermissionStatus.granted;
    }

    return granted;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StepsNotifier, CurrentStepsNotifier>(
      builder: (context, stepsNotifier, currentStepsNotifier, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Steps",
                    style: Shared.fontStyle(32, FontWeight.w600, Shared.black),
                  ),
                  _progressBar(context, currentStepsNotifier),
                ],
              ),
              SizedBox(height: 20),
              _currentSteps(context, currentStepsNotifier),
              SizedBox(height: 15),
              _currentStepsProgress(
                context,
                stepsNotifier,
                currentStepsNotifier,
              ),
              SizedBox(height: 10),
              _stepsGoal(context, stepsNotifier),
            ],
          ),
        );
      },
    );
  }

  Widget _progressBar(
    BuildContext context,
    CurrentStepsNotifier currentStepsNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isInitialized
            ? Shared.orange.withValues(alpha: 0.1)
            : Shared.lightGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _isInitialized ? Shared.orange : Shared.lightGray,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            _isInitialized ? "Active" : "Inactive",
            style: Shared.fontStyle(
              20,
              FontWeight.w500,
              _isInitialized ? Shared.orange : Shared.lightGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentSteps(
    BuildContext context,
    CurrentStepsNotifier currentStepsNotifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${currentStepsNotifier.currentSteps}",
          style: Shared.fontStyle(48, FontWeight.bold, Shared.orange),
        ),
        const SizedBox(width: 8),
        Text(
          "steps",
          style: Shared.fontStyle(24, FontWeight.w500, Shared.gray),
        ),
      ],
    );
  }

  Widget _currentStepsProgress(
    BuildContext context,
    StepsNotifier stepsNotifier,
    CurrentStepsNotifier currentStepsNotifier,
  ) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Shared.lightGray2,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (currentStepsNotifier.currentSteps / stepsNotifier.steps)
            .clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Shared.orange,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _stepsGoal(BuildContext context, StepsNotifier stepsNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("0", style: Shared.fontStyle(24, FontWeight.w500, Shared.gray)),
        Text(
          "Goal: ${stepsNotifier.steps}",
          style: Shared.fontStyle(24, FontWeight.w500, Shared.gray),
        ),
      ],
    );
  }
}
