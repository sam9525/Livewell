import 'package:flutter/material.dart';
import '../shared/shared.dart';
import 'widgets/medication_list.dart';
import 'widgets/vaccination_list.dart';

class Health {
  static Widget healthPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Shared.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // Medications Section
                MedicationList(),
                SizedBox(height: 20),
                VaccinationList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
