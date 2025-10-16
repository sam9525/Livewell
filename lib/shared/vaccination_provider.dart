import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/vaccination_model.dart';
import '../config/app_config.dart';
import '../auth/backend_auth.dart';

class VaccinationProvider with ChangeNotifier {
  List<Vaccination> _vaccinations = [];
  bool _isLoading = false;
  String? _error;

  List<Vaccination> get vaccinations => _vaccinations;
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

  // Load all vaccinations from backend
  Future<void> loadVaccinations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(AppConfig.vaccineUrl),
        headers: BackendAuth().getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> vaccinationsJson = json.decode(response.body);
        _vaccinations = vaccinationsJson
            .map((vaccination) => Vaccination.fromMap(vaccination))
            .toList();
      } else {
        _error = 'Failed to load vaccinations: ${response.statusCode}';
        debugPrint(_error);
      }
    } catch (e) {
      _error = 'Error loading vaccinations: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new vaccination
  Future<bool> addVaccination(Vaccination vaccination) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(AppConfig.vaccineUrl),
        headers: BackendAuth().getAuthHeaders(),
        body: json.encode(vaccination.toCreateMap()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final newVaccination = Vaccination.fromMap(responseData);
        _vaccinations.add(newVaccination);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _handleError(
          'Failed to add vaccination',
          'HTTP ${response.statusCode}',
          json.encode(vaccination.toMap()),
        );
        return false;
      }
    } catch (e) {
      _handleError(
        'Error adding vaccination',
        e,
        json.encode(vaccination.toMap()),
      );
      return false;
    }
  }

  // Update an existing vaccination
  Future<bool> updateVaccination(Vaccination vaccination) async {
    // Ensure vaccination has an ID for update
    if (vaccination.id == null) {
      _error = 'Cannot update vaccination: ID is required';
      debugPrint(_error);
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('${AppConfig.vaccineUrl}/${vaccination.id}'),
        headers: BackendAuth().getAuthHeaders(),
        body: json.encode(vaccination.toMap()),
      );

      if (response.statusCode == 200) {
        final index = _vaccinations.indexWhere((v) => v.id == vaccination.id);
        if (index != -1) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          _vaccinations[index] = Vaccination.fromMap(responseData);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _handleError('Failed to update vaccination', 'HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _handleError('Error updating vaccination', e);
      return false;
    }
  }

  // Delete a vaccination
  Future<bool> deleteVaccination(String vaccinationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.vaccineUrl}/$vaccinationId'),
        headers: BackendAuth().getAuthHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _vaccinations.removeWhere((vaccination) => vaccination.id == vaccinationId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _handleError('Failed to delete vaccination', 'HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _handleError('Error deleting vaccination', e);
      return false;
    }
  }

  // Get vaccination by ID (from local cache or fetch from backend)
  Future<Vaccination?> getVaccinationById(String id) async {
    // First check local cache
    try {
      final cachedVaccination = _vaccinations.firstWhere(
        (vaccination) => vaccination.id == id,
      );
      return cachedVaccination;
    } catch (e) {
      // Not in cache, fetch from backend
      try {
        final response = await http.get(
          Uri.parse('${AppConfig.vaccineUrl}/$id'),
          headers: BackendAuth().getAuthHeaders(),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> vaccinationData = json.decode(
            response.body,
          );
          return Vaccination.fromMap(vaccinationData);
        } else {
          debugPrint('Failed to get vaccination by ID: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        debugPrint('Error getting vaccination by ID: $e');
        return null;
      }
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

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
