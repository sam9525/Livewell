import 'package:flutter/material.dart';
import '../../shared/goal_provider.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import 'package:fl_chart/fl_chart.dart';

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
            weeklyNames[currentWeekIndex],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Shared.orange,
              fontSize: 20,
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
  final List<List<int>> weeklyDataTimes;
  final int weekIndex;
  final List<String> weekDays;

  const BuildLineChart({
    super.key,
    required this.weeklyDataTimes,
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
          maxY: 120,
          lineBarsData: [
            LineChartBarData(
              color: Shared.orange,
              spots: weeklyDataTimes[weekIndex].isNotEmpty
                  ? List.generate(
                      weeklyDataTimes[weekIndex].length,
                      (i) => FlSpot(
                        i.toDouble(),
                        weeklyDataTimes[weekIndex][i].toDouble(),
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
                    "${touchedSpots.first.y.toInt()}",
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
                interval: 20,
                showTitles: true,
                reservedSize: 50,
                maxIncluded: true,
                getTitlesWidget: leftTitleWidgets,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
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

    return SideTitleWidget(
      space: 6,
      meta: meta,
      fitInside: SideTitleFitInsideData.disable(),
      child: Text(
        weekDays[value.toInt()],
        style: Shared.fontStyle(24, FontWeight.w500, Shared.gray),
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
        value.toInt().toString(),
        style: Shared.fontStyle(24, FontWeight.w500, Shared.gray),
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
    return Consumer2<WaterIntakeNotifier, CurrentWaterIntakeNotifier>(
      builder: (context, waterIntakeNotifier, currentWaterIntakeNotifier, child) {
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "0",
                  style: Shared.fontStyle(24, FontWeight.w500, Shared.black),
                ),
                Text(
                  waterIntakeNotifier.waterIntake.toString(),
                  style: Shared.fontStyle(24, FontWeight.w500, Shared.black),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _addWaterButton(context, currentWaterIntakeNotifier, "+250 ml"),
                SizedBox(width: 30),
                _addWaterButton(context, currentWaterIntakeNotifier, "+500 ml"),
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
          currentWaterIntakeNotifier.setWaterIntake(value.toInt());
        },
      ),
    );
  }

  Widget _addWaterButton(
    BuildContext context,
    CurrentWaterIntakeNotifier currentWaterIntakeNotifier,
    String text,
  ) {
    return ElevatedButton(
      onPressed: () {
        if (text == "+250 ml") {
          currentWaterIntakeNotifier.add250ml();
        } else if (text == "+500 ml") {
          currentWaterIntakeNotifier.add500ml();
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
