import 'package:flutter/material.dart';
import '../shared/shared.dart';
import 'widgets/vaccination_list.dart';

/// Demo page showing how to use the vaccination system
/// This can be integrated into your existing navigation or used as a standalone page
class VaccinationDemo extends StatelessWidget {
  const VaccinationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Shared.bgColor,
      appBar: AppBar(
        backgroundColor: Shared.bgColor,
        elevation: 0,
        title: Text(
          'Vaccination Tracker',
          style: Shared.fontStyle(32, FontWeight.bold, Shared.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Shared.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const VaccinationList(),
    );
  }
}
