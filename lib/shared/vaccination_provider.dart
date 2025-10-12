import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/vaccination_model.dart';

class VaccinationProvider with ChangeNotifier {
  List<Vaccination> _vaccinations = [];
  bool _isLoading = false;

  List<Vaccination> get vaccinations => _vaccinations;
  bool get isLoading => _isLoading;

  // Load vaccinations from SharedPreferences
  Future<void> loadVaccinations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final vaccinationsJson = prefs.getString('vaccinations');

      if (vaccinationsJson != null) {
        final List<dynamic> vaccinationsList = json.decode(vaccinationsJson);
        _vaccinations = vaccinationsList
            .map((vaccination) => Vaccination.fromMap(vaccination))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading vaccinations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save vaccinations to SharedPreferences
  Future<void> _saveVaccinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vaccinationsJson = json.encode(
        _vaccinations.map((vaccination) => vaccination.toMap()).toList(),
      );
      await prefs.setString('vaccinations', vaccinationsJson);
    } catch (e) {
      debugPrint('Error saving vaccinations: $e');
    }
  }

  // Add a new vaccination
  Future<void> addVaccination(Vaccination vaccination) async {
    _vaccinations.add(vaccination);
    await _saveVaccinations();
    notifyListeners();
  }

  // Update an existing vaccination
  Future<void> updateVaccination(Vaccination vaccination) async {
    final index = _vaccinations.indexWhere((v) => v.id == vaccination.id);
    if (index != -1) {
      _vaccinations[index] = vaccination;
      await _saveVaccinations();
      notifyListeners();
    }
  }

  // Delete a vaccination
  Future<void> deleteVaccination(String vaccinationId) async {
    _vaccinations.removeWhere((vaccination) => vaccination.id == vaccinationId);
    await _saveVaccinations();
    notifyListeners();
  }

  // Get vaccination by ID
  Vaccination? getVaccinationById(String id) {
    try {
      return _vaccinations.firstWhere((vaccination) => vaccination.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get upcoming vaccinations (next dose date is in the future)
  List<Vaccination> getUpcomingVaccinations() {
    final today = DateTime.now();
    return _vaccinations.where((vaccination) {
      return vaccination.nextDoseDate != null &&
          vaccination.nextDoseDate!.isAfter(today);
    }).toList();
  }

  // Get vaccinations by date range
  List<Vaccination> getVaccinationsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _vaccinations.where((vaccination) {
      return vaccination.doseDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          vaccination.doseDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
}
