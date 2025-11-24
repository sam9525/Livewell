import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/medication_model.dart';
import '../config/app_config.dart';
import '../auth/backend_auth.dart';

class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];
  bool _isLoading = false;
  String? _error;

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper method to handle common error patterns
  void _handleError(String message, Object error, [dynamic debugData]) {
    _error = '$message: $error';
    debugPrint(_error);
    if (debugData != null) {
      debugPrint(debugData.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  // Load all medications from backend
  Future<void> loadMedications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(AppConfig.medicationUrl),
        headers: BackendAuth().getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> medicationsJson = json.decode(response.body);
        _medications = medicationsJson
            .map((medication) => Medication.fromMap(medication))
            .toList();
      } else {
        _error = 'Failed to load medications: ${response.statusCode}';
        debugPrint(_error);
      }
    } catch (e) {
      _error = 'Error loading medications: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new medication
  Future<bool> addMedication(Medication medication) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(AppConfig.medicationUrl),
        headers: BackendAuth().getAuthHeaders(),
        body: json.encode(medication.toCreateMap()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final newMedication = Medication.fromMap(responseData);
        _medications.add(newMedication);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _handleError(
          'Failed to add medication',
          'HTTP ${response.statusCode}',
          json.encode(medication.toMap()),
        );
        return false;
      }
    } catch (e) {
      _handleError(
        'Error adding medication',
        e,
        json.encode(medication.toMap()),
      );
      return false;
    }
  }

  // Update an existing medication
  Future<bool> updateMedication(Medication medication) async {
    // Ensure medication has an ID for update
    if (medication.id == null) {
      _error = 'Cannot update medication: ID is required';
      debugPrint(_error);
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('${AppConfig.medicationUrl}/${medication.id}'),
        headers: BackendAuth().getAuthHeaders(),
        body: json.encode(medication.toMap()),
      );

      if (response.statusCode == 200) {
        final index = _medications.indexWhere((m) => m.id == medication.id);
        if (index != -1) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          _medications[index] = Medication.fromMap(responseData);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _handleError(
          'Failed to update medication',
          'HTTP ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      _handleError('Error updating medication', e);
      return false;
    }
  }

  // Delete a medication
  Future<bool> deleteMedication(String medicationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.medicationUrl}/$medicationId'),
        headers: BackendAuth().getAuthHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _medications.removeWhere((medication) => medication.id == medicationId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _handleError(
          'Failed to delete medication',
          'HTTP ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      _handleError('Error deleting medication', e);
      return false;
    }
  }

  // Get medication by ID (from local cache or fetch from backend)
  Future<Medication?> getMedicationById(String id) async {
    // First check local cache
    try {
      final cachedMedication = _medications.firstWhere(
        (medication) => medication.id == id,
      );
      return cachedMedication;
    } catch (e) {
      // Not in cache, fetch from backend
      try {
        final response = await http.get(
          Uri.parse('${AppConfig.medicationUrl}/$id'),
          headers: BackendAuth().getAuthHeaders(),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> medicationData = json.decode(
            response.body,
          );
          return Medication.fromMap(medicationData);
        } else {
          debugPrint('Failed to get medication by ID: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        debugPrint('Error getting medication by ID: $e');
        return null;
      }
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

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
