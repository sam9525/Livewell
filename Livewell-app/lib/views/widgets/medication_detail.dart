import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import '../../shared/medication_provider.dart';
import '../../model/medication_model.dart';
import 'medication_form.dart';

class MedicationDetail extends StatelessWidget {
  final Medication medication;

  const MedicationDetail({super.key, required this.medication});

  // Format date to display format (DD/MM/YYYY)
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Shared.bgColor,
      appBar: AppBar(
        backgroundColor: Shared.bgColor,
        elevation: 0,
        title: Text(
          'Medication Details',
          style: Shared.fontStyle(32, FontWeight.bold, Shared.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Shared.black, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildDetailsCard(),
            const SizedBox(height: 20),
            _buildScheduleCard(),
            if (medication.notes != null) ...[
              const SizedBox(height: 20),
              _buildNotesCard(),
            ],
            const SizedBox(height: 30),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Shared.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.medication, size: 40, color: Shared.orange),
          ),
          const SizedBox(height: 20),
          Text(
            medication.name,
            style: Shared.fontStyle(28, FontWeight.bold, Shared.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '${medication.dosage} ${medication.dosageUnit}',
            style: Shared.fontStyle(20, FontWeight.w600, Shared.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medication Details',
            style: Shared.fontStyle(28, FontWeight.bold, Shared.black),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            Icons.medication,
            'Dosage',
            '${medication.dosage} ${medication.dosageUnit}',
          ),
          const SizedBox(height: 15),
          _buildDetailRow(Icons.repeat, 'Frequency', medication.frequency),
          const SizedBox(height: 15),
          _buildDetailRow(Icons.access_time, 'Time', medication.time),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule',
            style: Shared.fontStyle(28, FontWeight.bold, Shared.black),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            Icons.calendar_today,
            'Start Date',
            _formatDate(medication.startDate),
          ),
          if (medication.durationDays != null) ...[
            const SizedBox(height: 15),
            _buildDetailRow(
              Icons.schedule,
              'Duration',
              '${medication.durationDays.toString()} days',
            ),
            const SizedBox(height: 15),
            _buildDetailRow(
              Icons.event,
              'End Date',
              _formatDate(
                medication.startDate.add(
                  Duration(days: medication.durationDays!),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.notes, color: Shared.orange, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes',
                  style: Shared.fontStyle(24, FontWeight.w600, Shared.gray),
                ),
                const SizedBox(height: 5),
                Text(
                  medication.notes ?? '',
                  style: Shared.fontStyle(28, FontWeight.w500, Shared.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Shared.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: Shared.orange),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Shared.fontStyle(24, FontWeight.w500, Shared.gray),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Shared.fontStyle(20, FontWeight.w600, Shared.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _navigateToEdit(context),
            style: Shared.buttonStyle(
              double.infinity,
              50,
              Shared.orange,
              Colors.white,
            ),
            icon: const Icon(Icons.edit, color: Colors.white, size: 24),
            label: Text(
              'Edit',
              style: Shared.fontStyle(24, FontWeight.bold, Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showDeleteDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              fixedSize: const Size(double.infinity, 50),
              elevation: 5,
            ),
            icon: const Icon(Icons.delete, color: Colors.white, size: 24),
            label: Text(
              'Delete',
              style: Shared.fontStyle(24, FontWeight.bold, Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MedicationForm(
          medication: medication,
          onSaved: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Medication',
          style: Shared.fontStyle(20, FontWeight.bold, Shared.black),
        ),
        content: Text(
          'Are you sure you want to delete "${medication.name}"?',
          style: Shared.fontStyle(16, FontWeight.w500, Shared.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: Shared.fontStyle(16, FontWeight.w500, Shared.gray),
            ),
          ),
          TextButton(
            onPressed: () {
              if (medication.medId != '') {
                Provider.of<MedicationProvider>(
                  context,
                  listen: false,
                ).deleteMedication(medication.medId);
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to list
              }
            },
            child: Text(
              'Delete',
              style: Shared.fontStyle(16, FontWeight.bold, Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
