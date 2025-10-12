import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/medication_model.dart';

class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];
  bool _isLoading = false;

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;

  // Load medications from SharedPreferences
  Future<void> loadMedications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsJson = prefs.getString('medications');

      if (medicationsJson != null) {
        final List<dynamic> medicationsList = json.decode(medicationsJson);
        _medications = medicationsList
            .map((medication) => Medication.fromMap(medication))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading medications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save medications to SharedPreferences
  Future<void> _saveMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsJson = json.encode(
        _medications.map((medication) => medication.toMap()).toList(),
      );
      await prefs.setString('medications', medicationsJson);
    } catch (e) {
      debugPrint('Error saving medications: $e');
    }
  }

  // Add a new medication
  Future<void> addMedication(Medication medication) async {
    _medications.add(medication);
    await _saveMedications();
    notifyListeners();
  }

  // Update an existing medication
  Future<void> updateMedication(Medication medication) async {
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      _medications[index] = medication;
      await _saveMedications();
      notifyListeners();
    }
  }

  // Delete a medication
  Future<void> deleteMedication(String medicationId) async {
    _medications.removeWhere((medication) => medication.id == medicationId);
    await _saveMedications();
    notifyListeners();
  }

  // Get medication by ID
  Medication? getMedicationById(String id) {
    try {
      return _medications.firstWhere((medication) => medication.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get medications for today
  List<Medication> getTodaysMedications() {
    final today = DateTime.now();
    return _medications.where((medication) {
      // Check if medication is active today based on start date and duration
      if (medication.startDate.isAfter(today)) return false;

      if (medication.durationDays != null) {
        final endDate = medication.startDate.add(
          Duration(days: medication.durationDays!),
        );
        if (endDate.isBefore(today)) return false;
      }

      return true;
    }).toList();
  }
}
