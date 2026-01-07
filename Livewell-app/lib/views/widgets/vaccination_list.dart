import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../shared/shared.dart';
import '../../shared/vaccination_provider.dart';
import '../../model/vaccination_model.dart';
import 'vaccination_form.dart';
import 'vaccination_detail.dart';
import '../chatbot_page.dart';
import '../navigation.dart';

class VaccinationList extends StatefulWidget {
  const VaccinationList({super.key});

  @override
  State<VaccinationList> createState() => _VaccinationListState();
}

class _VaccinationListState extends State<VaccinationList>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VaccinationProvider>(
        context,
        listen: false,
      ).loadVaccinations();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh vaccinations when app becomes active
      Provider.of<VaccinationProvider>(
        context,
        listen: false,
      ).loadVaccinations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              toolbarHeight: 80,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                'My Vaccinations',
                style: Shared.fontStyle(32, FontWeight.bold, Shared.black),
              ),
              actions: [
                // Add vaccination button
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Shared.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FloatingActionButton(
                    onPressed: () => _navigateToForm(),
                    backgroundColor: Shared.orange,
                    elevation: 0,
                    heroTag: "vaccination_fab",
                    child: const Icon(
                      Icons.add,
                      color: Shared.bgColor,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
            body: Consumer<VaccinationProvider>(
              builder: (context, vaccinationProvider, child) {
                if (vaccinationProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vaccinationProvider.vaccinations.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: vaccinationProvider.vaccinations.length,
                  itemBuilder: (context, index) {
                    final vaccination = vaccinationProvider.vaccinations[index];
                    return _buildVaccinationCard(vaccination);
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Chatbot button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _navigateToChatbot(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Shared.orange,
              foregroundColor: Shared.bgColor,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Shared.orange, width: 2),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/chatbot.svg',
                  height: 32,
                  width: 32,
                  colorFilter: ColorFilter.mode(
                    Shared.bgColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Add With AI',
                  style: Shared.fontStyle(24, FontWeight.bold, Shared.bgColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vaccines, size: 80, color: Shared.lightGray),
          const SizedBox(height: 20),
          Text(
            'No vaccinations added yet',
            style: Shared.fontStyle(24, FontWeight.w600, Shared.gray),
          ),
          const SizedBox(height: 30),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _navigateToForm(),
                style: Shared.buttonStyle(200, 50, Shared.orange, Colors.white),
                child: Text(
                  'Add Vaccination',
                  style: Shared.fontStyle(18, FontWeight.bold, Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => _navigateToChatbot(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Shared.orange,
                  side: BorderSide(color: Shared.orange, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(200, 50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/chatbot.svg',
                      height: 24,
                      width: 24,
                      colorFilter: ColorFilter.mode(
                        Shared.orange,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add With AI',
                      style: Shared.fontStyle(
                        18,
                        FontWeight.bold,
                        Shared.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(Vaccination vaccination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Shared.bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _navigateToDetail(vaccination),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Shared.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.vaccines,
                        color: Shared.orange,
                        size: 24,
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
                              20,
                              FontWeight.bold,
                              Shared.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            vaccination.location ?? '',
                            style: Shared.fontStyle(
                              16,
                              FontWeight.w500,
                              Shared.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleMenuAction(value, vaccination),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Shared.orange),
                              SizedBox(width: 10),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 10),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Shared.gray),
                    const SizedBox(width: 8),
                    Text(
                      'Dose Date: ${_formatDate(vaccination.doseDate)}',
                      style: Shared.fontStyle(16, FontWeight.w500, Shared.gray),
                    ),
                  ],
                ),
                if (vaccination.nextDoseDate != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 18, color: Shared.gray),
                      const SizedBox(width: 8),
                      Text(
                        'Next Dose: ${_formatDate(vaccination.nextDoseDate!)}',
                        style: Shared.fontStyle(
                          16,
                          FontWeight.w500,
                          Shared.gray,
                        ),
                      ),
                    ],
                  ),
                ],
                if (vaccination.notes != '') ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Shared.lightGray2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vaccination.notes ?? '',
                      style: Shared.fontStyle(14, FontWeight.w400, Shared.gray),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToForm([Vaccination? vaccination]) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => VaccinationForm(
              vaccination: vaccination,
              onSaved: () {
                // Refresh the list
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Provider.of<VaccinationProvider>(
                      context,
                      listen: false,
                    ).loadVaccinations();
                  }
                });
              },
            ),
          ),
        )
        .then((_) {
          // Refresh the list
          if (mounted) {
            Provider.of<VaccinationProvider>(
              context,
              listen: false,
            ).loadVaccinations();
          }
        });
  }

  void _navigateToDetail(Vaccination vaccination) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => VaccinationDetail(vaccination: vaccination),
          ),
        )
        .then((_) {
          // Refresh the list when returning from detail view
          if (mounted) {
            Provider.of<VaccinationProvider>(
              context,
              listen: false,
            ).loadVaccinations();
          }
        });
  }

  void _navigateToChatbot() {
    // Clear chatbot history before navigating
    Chatbot.addChatHistoryForVaccination();
    // Navigate to the chatbot page
    HomePage.navigateToRoute(context, '/chatbot');
  }

  void _handleMenuAction(String action, Vaccination vaccination) {
    switch (action) {
      case 'edit':
        _navigateToForm(vaccination);
        break;
      case 'delete':
        _showDeleteDialog(vaccination);
        break;
    }
  }

  void _showDeleteDialog(Vaccination vaccination) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Vaccination',
          style: Shared.fontStyle(20, FontWeight.bold, Shared.black),
        ),
        content: Text(
          'Are you sure you want to delete "${vaccination.name}"?',
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
              if (vaccination.vacId != '') {
                Provider.of<VaccinationProvider>(
                  context,
                  listen: false,
                ).deleteVaccination(vaccination.vacId);
                Navigator.of(context).pop();

                // Reload page
                Provider.of<VaccinationProvider>(
                  context,
                  listen: false,
                ).loadVaccinations();
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
