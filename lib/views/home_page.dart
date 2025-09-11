import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/shared.dart';
import 'widgets/home_widgets.dart';
import '../shared/date_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DateProvider>(
      builder: (context, dateProvider, child) {
        // Check if the tracking data is available
        bool hasData =
            !dateProvider.isLoading &&
            dateProvider.weeklySteps.isNotEmpty &&
            dateProvider.currentWeekIndex < dateProvider.weeklySteps.length &&
            dateProvider.weeklySteps[dateProvider.currentWeekIndex].isNotEmpty;

        return Container(
          color: Shared.bgColor,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              WeeklyName(
                weeklyNames: dateProvider.weeklyNames,
                currentWeekIndex: dateProvider.currentWeekIndex,
                canGoPrevious: dateProvider.canGoPrevious,
                canGoNext: dateProvider.canGoNext,
                previousWeek: dateProvider.previousWeek,
                nextWeek: dateProvider.nextWeek,
              ),
              dateProvider.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Shared.orange),
                    )
                  : hasData
                  ? BuildLineChart(
                      weeklySteps: dateProvider.weeklySteps,
                      weekIndex: dateProvider.currentWeekIndex,
                      weekDays: AppConstants.weekDays,
                    )
                  : Center(child: Text("No data available")),
              WaterIntakeSliders(),
            ],
          ),
        );
      },
    );
  }
}
