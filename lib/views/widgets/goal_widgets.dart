import 'package:flutter/material.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import '../../shared/goal_provider.dart';
import 'dart:async';

class NumberPicker extends StatelessWidget {
  final String title;
  final int begin;
  final int end;
  final int jump;
  final bool isWaterIntake;

  const NumberPicker({
    super.key,
    required this.title,
    required this.begin,
    required this.end,
    required this.jump,
    this.isWaterIntake = true,
  });

  @override
  Widget build(BuildContext context) {
    return isWaterIntake
        ? _buildPicker<WaterIntakeNotifier>(
            context,
            (notifier) => notifier.selected,
            (notifier, value) => notifier.setWaterIntake(value),
            (selected) => selected * 50 + 500,
          )
        : _buildPicker<StepsNotifier>(
            context,
            (notifier) => notifier.selected,
            (notifier, value) => notifier.setSteps(value),
            (selected) => selected * 100 + 2000,
          );
  }

  Widget _buildPicker<T extends ChangeNotifier>(
    BuildContext context,
    int Function(T) getSelected,
    void Function(T, int) setValue,
    int Function(int) valueTransform,
  ) {
    Timer? debounceTimer;
    return Consumer<T>(
      builder: (context, notifier, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Picker(
            adapter: NumberPickerAdapter(
              data: [NumberPickerColumn(begin: begin, end: end, jump: jump)],
            ),
            height: 200,
            title: Text(
              title,
              style: Shared.fontStyle(32, FontWeight.w600, Shared.black),
            ),
            headerDecoration: const BoxDecoration(),
            cancelText: '',
            confirmText: '',
            textStyle: Shared.fontStyle(32, FontWeight.normal, Shared.darkGray),
            selecteds: [getSelected(notifier)],
            selectedTextStyle: Shared.fontStyle(
              36,
              FontWeight.bold,
              Shared.orange,
            ),
            selectionOverlay: const SizedBox.shrink(),
            itemExtent: 50.0,
            onSelect: (picker, index, selecteds) {
              debounceTimer?.cancel();

              // Set new timer, return the value after 1 second
              debounceTimer = Timer(const Duration(milliseconds: 1000), () {
                setValue(notifier, valueTransform(selecteds[index]));
              });
            },
          ).makePicker(),
        );
      },
    );
  }
}
