import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import '../../shared/medication_provider.dart';
import '../../model/medication_model.dart';

class MedicationForm extends StatefulWidget {
  final Medication? medication;
  final VoidCallback? onSaved;

  const MedicationForm({super.key, this.medication, this.onSaved});

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedDosageUnit = DosageUnit.mg.value;
  String _selectedFrequency = Frequency.daily.value;
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedStartDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final medication = widget.medication!;
    _nameController.text = medication.name;
    _dosageController.text = medication.dosage.toString();
    _selectedDosageUnit = medication.dosageUnit;
    _selectedFrequency = medication.frequency;
    _notesController.text = medication.notes;
    _selectedStartDate = medication.startDate;
    _durationController.text = medication.durationDays?.toString() ?? '';

    // Parse time from string (assuming format "HH:mm")
    final timeParts = medication.time.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  void _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      final medication = Medication(
        id: widget
            .medication
            ?.id, // Preserve existing ID for updates, null for new
        name: _nameController.text.trim(),
        dosage: int.parse(_dosageController.text),
        dosageUnit: _selectedDosageUnit,
        frequency: _selectedFrequency,
        time:
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        startDate: _selectedStartDate,
        durationDays: _durationController.text.trim().isNotEmpty
            ? int.tryParse(_durationController.text.trim())
            : null,
        notes: _notesController.text.trim(),
      );

      final medicationProvider = Provider.of<MedicationProvider>(
        context,
        listen: false,
      );

      bool success;
      if (widget.medication != null) {
        success = await medicationProvider.updateMedication(medication);
      } else {
        success = await medicationProvider.addMedication(medication);
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
                medicationProvider.error ?? 'Failed to save medication',
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
          widget.medication != null ? 'Edit Medication' : 'Add Medication',
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
              // Medication Name
              Text(
                'Medication Name',
                style: Shared.fontStyle(24, FontWeight.w600, Shared.black),
              ),
              Shared.inputContainer(
                double.infinity,
                'Enter medication name',
                _nameController,
              ),
              const SizedBox(height: 20),

              // Dosage
              Text(
                'Dosage',
                style: Shared.fontStyle(24, FontWeight.w600, Shared.black),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Shared.inputContainer(
                      double.infinity,
                      '0',
                      _dosageController,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Shared.black, width: 2),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          itemHeight: 60,
                          value: _selectedDosageUnit,
                          isExpanded: true,
                          items: DosageUnit.values.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit.value,
                              child: Text(
                                unit.value,
                                style: Shared.fontStyle(
                                  24,
                                  FontWeight.w500,
                                  Shared.black,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDosageUnit = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Frequency
              Text(
                'Frequency',
                style: Shared.fontStyle(24, FontWeight.w600, Shared.black),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Shared.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    itemHeight: 60,
                    value: _selectedFrequency,
                    isExpanded: true,
                    items: Frequency.values.map((frequency) {
                      return DropdownMenuItem<String>(
                        value: frequency.value,
                        child: Text(
                          frequency.value,
                          style: Shared.fontStyle(
                            24,
                            FontWeight.w500,
                            Shared.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFrequency = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time
              Text(
                'Time',
                style: Shared.fontStyle(24, FontWeight.w600, Shared.black),
              ),
              GestureDetector(
                onTap: _selectTime,
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
                      Icon(Icons.access_time, color: Shared.black, size: 32),
                      const SizedBox(width: 10),
                      Text(
                        _selectedTime.format(context),
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

              // Start Date
              Text(
                'Start Date',
                style: Shared.fontStyle(24, FontWeight.w600, Shared.black),
              ),
              GestureDetector(
                onTap: _selectDate,
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
                        '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
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

              // Duration
              Text(
                'Duration (days) - Optional',
                style: Shared.fontStyle(24, FontWeight.w600, Shared.black),
              ),
              Shared.inputContainer(
                double.infinity,
                'Enter duration in days',
                _durationController,
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
                  onPressed: _saveMedication,
                  style: Shared.buttonStyle(
                    double.infinity,
                    60,
                    Shared.orange,
                    Colors.white,
                  ),
                  child: Text(
                    widget.medication != null
                        ? 'Update Medication'
                        : 'Save Medication',
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
