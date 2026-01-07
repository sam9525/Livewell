import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import '../../shared/vaccination_provider.dart';
import '../../model/vaccination_model.dart';

class VaccinationForm extends StatefulWidget {
  final Vaccination? vaccination;
  final VoidCallback? onSaved;

  const VaccinationForm({super.key, this.vaccination, this.onSaved});

  @override
  State<VaccinationForm> createState() => _VaccinationFormState();
}

class _VaccinationFormState extends State<VaccinationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDoseDate = DateTime.now();
  DateTime? _selectedNextDoseDate;

  @override
  void initState() {
    super.initState();
    if (widget.vaccination != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final vaccination = widget.vaccination!;
    _nameController.text = vaccination.name;
    _locationController.text = vaccination.location ?? '';
    _notesController.text = vaccination.notes ?? '';
    _selectedDoseDate = vaccination.doseDate;
    _selectedNextDoseDate = vaccination.nextDoseDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDoseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDoseDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDoseDate) {
      setState(() {
        _selectedDoseDate = picked;
      });
    }
  }

  Future<void> _selectNextDoseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedNextDoseDate ??
          _selectedDoseDate.add(const Duration(days: 30)),
      firstDate: _selectedDoseDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _selectedNextDoseDate) {
      setState(() {
        _selectedNextDoseDate = picked;
      });
    }
  }

  void _clearNextDoseDate() {
    setState(() {
      _selectedNextDoseDate = null;
    });
  }

  void _saveVaccination() async {
    if (_formKey.currentState!.validate()) {
      final vaccination = Vaccination(
        vacId: widget.vaccination?.vacId ?? '',
        name: _nameController.text.trim(),
        doseDate: _selectedDoseDate,
        nextDoseDate: _selectedNextDoseDate,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
      );

      final vaccinationProvider = Provider.of<VaccinationProvider>(
        context,
        listen: false,
      );

      bool success;
      if (widget.vaccination != null) {
        success = await vaccinationProvider.updateVaccination(vaccination);
      } else {
        success = await vaccinationProvider.addVaccination(vaccination);
      }

      if (success) {
        // Call the onSaved callback to trigger parent rebuild
        if (widget.onSaved != null) {
          widget.onSaved!();
        }

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                vaccinationProvider.error ?? 'Failed to save vaccination',
                style: Shared.fontStyle(16, FontWeight.w500, Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Shared.bgColor,
      appBar: AppBar(
        backgroundColor: Shared.bgColor,
        elevation: 0,
        title: Text(
          widget.vaccination != null ? 'Edit Vaccination' : 'Add Vaccination',
          style: Shared.fontStyle(32, FontWeight.bold, Shared.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Shared.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vaccination Name
              Text(
                'Vaccination Name',
                style: Shared.fontStyle(24, FontWeight.w600, Shared.black),
              ),
              Shared.inputContainer(
                double.infinity,
                'Enter vaccination name',
                _nameController,
              ),
              const SizedBox(height: 20),

              // Dose Date
              Text(
                'Dose Date',
                style: Shared.fontStyle(24, FontWeight.w600, Shared.black),
              ),
              GestureDetector(
                onTap: _selectDoseDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Shared.black, width: 2),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Shared.black, size: 32),
                      const SizedBox(width: 10),
                      Text(
                        '${_selectedDoseDate.day}/${_selectedDoseDate.month}/${_selectedDoseDate.year}',
                        style: Shared.fontStyle(
                          24,
                          FontWeight.w500,
                          Shared.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Next Dose Date (Optional)
              Row(
                children: [
                  Text(
                    'Next Dose Date',
                    style: Shared.fontStyle(24, FontWeight.w600, Shared.black),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '(Optional)',
                    style: Shared.fontStyle(20, FontWeight.w400, Shared.gray),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _selectNextDoseDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Shared.black, width: 2),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Shared.black, size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedNextDoseDate != null
                              ? '${_selectedNextDoseDate!.day}/${_selectedNextDoseDate!.month}/${_selectedNextDoseDate!.year}'
                              : 'Select next dose date',
                          style: Shared.fontStyle(
                            24,
                            FontWeight.w500,
                            _selectedNextDoseDate != null
                                ? Shared.black
                                : Shared.lightGray,
                          ),
                        ),
                      ),
                      if (_selectedNextDoseDate != null)
                        IconButton(
                          onPressed: _clearNextDoseDate,
                          icon: Icon(Icons.clear, color: Shared.gray, size: 24),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Location
              Row(
                children: [
                  Text(
                    'Location',
                    style: Shared.fontStyle(24, FontWeight.w600, Shared.black),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '(Optional)',
                    style: Shared.fontStyle(20, FontWeight.w400, Shared.gray),
                  ),
                ],
              ),
              Shared.inputContainer(
                double.infinity,
                'Enter vaccination location',
                _locationController,
              ),
              const SizedBox(height: 20),

              // Notes
              Text(
                'Notes',
                style: Shared.fontStyle(24, FontWeight.w600, Shared.black),
              ),
              SizedBox(
                width: double.infinity,
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: Shared.fontStyle(24, FontWeight.w500, Shared.black),
                  decoration: InputDecoration(
                    hintText: 'Enter any additional notes',
                    hintStyle: Shared.fontStyle(
                      24,
                      FontWeight.w500,
                      Shared.lightGray,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Shared.black, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Shared.orange, width: 3),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _saveVaccination,
                  style: Shared.buttonStyle(
                    double.infinity,
                    60,
                    Shared.orange,
                    Colors.white,
                  ),
                  child: Text(
                    widget.vaccination != null
                        ? 'Update Vaccination'
                        : 'Save Vaccination',
                    style: Shared.fontStyle(24, FontWeight.bold, Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
