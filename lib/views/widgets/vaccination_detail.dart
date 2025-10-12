import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import '../../shared/vaccination_provider.dart';
import '../../model/vaccination_model.dart';
import 'vaccination_form.dart';

class VaccinationDetail extends StatelessWidget {
  final Vaccination vaccination;

  const VaccinationDetail({super.key, required this.vaccination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Shared.bgColor,
      appBar: AppBar(
        backgroundColor: Shared.bgColor,
        elevation: 0,
        title: Text(
          'Vaccination Details',
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
            // Header Card
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Shared.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.vaccines,
                          color: Shared.orange,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vaccination.name,
                              style: Shared.fontStyle(
                                28,
                                FontWeight.bold,
                                Shared.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dose Date Card
            _buildInfoCard(
              'Dose Date',
              _formatDate(vaccination.doseDate),
              Icons.calendar_today,
            ),
            const SizedBox(height: 15),

            // Next Dose Date Card (if available)
            if (vaccination.nextDoseDate != null) ...[
              _buildInfoCard(
                'Next Dose Date',
                _formatDate(vaccination.nextDoseDate!),
                Icons.schedule,
              ),
              const SizedBox(height: 15),
            ],

            // Location Card
            if (vaccination.location.isNotEmpty) ...[
              _buildInfoCard(
                'Location',
                vaccination.location,
                Icons.location_on,
              ),
            ],
            const SizedBox(height: 15),

            // Notes Card (if available)
            if (vaccination.notes.isNotEmpty) ...[
              _buildInfoCard('Notes', vaccination.notes, Icons.notes),
              const SizedBox(height: 15),
            ],

            // Created Date Card
            _buildInfoCard(
              'Added On',
              _formatDate(vaccination.createdAt),
              Icons.add_circle_outline,
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToEdit(context),
                    style: Shared.buttonStyle(
                      double.infinity,
                      50,
                      Shared.orange,
                      Colors.white,
                    ),
                    child: Text(
                      'Edit',
                      style: Shared.fontStyle(
                        24,
                        FontWeight.bold,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
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
                    child: Text(
                      'Delete',
                      style: Shared.fontStyle(
                        24,
                        FontWeight.bold,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
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
          Icon(icon, color: Shared.orange, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Shared.fontStyle(24, FontWeight.w600, Shared.gray),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: Shared.fontStyle(28, FontWeight.w500, Shared.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VaccinationForm(
          vaccination: vaccination,
          onSaved: () {
            // Refresh the detail view
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
          'Delete Vaccination',
          style: Shared.fontStyle(20, FontWeight.bold, Shared.black),
        ),
        content: Text(
          'Are you sure you want to delete "${vaccination.name}"? This action cannot be undone.',
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
              Provider.of<VaccinationProvider>(
                context,
                listen: false,
              ).deleteVaccination(vaccination.id);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to list
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
