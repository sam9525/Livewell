import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/shared.dart';
import '../../shared/location_provider.dart';
import '../../model/local_resource_model.dart';
import '../../services/local_resources_service.dart';

class LocalResourcesWidget extends StatefulWidget {
  const LocalResourcesWidget({super.key});

  @override
  State<LocalResourcesWidget> createState() => _LocalResourcesWidgetState();
}

class _LocalResourcesWidgetState extends State<LocalResourcesWidget> {
  final LocalResourcesService _resourcesService = LocalResourcesService();
  List<LocalResource> _resources = [];
  bool _isLoading = false;
  String _currentPostcode = '';

  @override
  void initState() {
    super.initState();
    // Load resources after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResources();
    });
  }

  Future<void> _loadResources() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final postcode = locationProvider.postcode;

    // Only load if postcode has changed
    if (postcode == _currentPostcode) return;

    setState(() {
      _isLoading = true;
      _currentPostcode = postcode;
    });

    try {
      final resources = await _resourcesService.getResourcesByPostcode(
        postcode,
      );
      if (mounted) {
        setState(() {
          _resources = resources;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading local resources: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _launchContact(String contactInfo) async {
    Uri? uri;
    String errorMessage = 'Could not launch';

    // Detect contact type and create appropriate URI
    if (contactInfo.contains('@')) {
      // Email
      uri = Uri.parse('mailto:$contactInfo');
      errorMessage = 'Could not launch email app';
    } else if (contactInfo.toLowerCase().startsWith('visit')) {
      // Website
      String url = contactInfo.toLowerCase().replaceAll('visit ', '');
      uri = Uri.parse(url);
      errorMessage = 'Could not open website';
    } else {
      // Phone number
      final phoneRegex = RegExp(r'\d{4}\s?\d{3}\s?\d{3}');
      final match = phoneRegex.firstMatch(contactInfo);

      if (match != null) {
        final phone = match.group(0)!.replaceAll(' ', '');
        uri = Uri.parse('tel:$phone');
        errorMessage = 'Could not launch phone dialer';
      }
    }

    if (uri != null) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: Shared.fontStyle(20, FontWeight.w500, Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _launchMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open Google Maps',
              style: Shared.fontStyle(20, FontWeight.w500, Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getContactIcon(String contactInfo) {
    if (contactInfo.contains('@')) {
      return Icons.email;
    } else if (contactInfo.toLowerCase().startsWith('http://') ||
        contactInfo.toLowerCase().startsWith('https://') ||
        contactInfo.toLowerCase().startsWith('www.')) {
      return Icons.language;
    } else {
      return Icons.phone;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'activity':
        return Icons.directions_walk;
      case 'health':
        return Icons.local_hospital;
      case 'social':
        return Icons.group;
      case 'support':
        return Icons.support_agent;
      default:
        return Icons.location_on;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'activity':
        return Colors.green;
      case 'health':
        return Colors.red;
      case 'social':
        return Colors.blue;
      case 'support':
        return Colors.purple;
      default:
        return Shared.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        // Reload resources if postcode changes
        if (locationProvider.postcode != _currentPostcode && !_isLoading) {
          Future.microtask(() => _loadResources());
        }

        // Don't show widget if loading and no resources yet
        if (_isLoading && _resources.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(color: Shared.orange),
            ),
          );
        }

        // Don't show widget if no resources
        if (_resources.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Container(
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
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Shared.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.location_city,
                              color: Shared.orange,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Local Resources',
                                  style: Shared.fontStyle(
                                    24,
                                    FontWeight.bold,
                                    Shared.black,
                                  ),
                                ),
                                Text(
                                  'Near ${locationProvider.suburb}',
                                  style: Shared.fontStyle(
                                    18,
                                    FontWeight.w500,
                                    Shared.gray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Refresh button
                          IconButton(
                            onPressed: _isLoading ? null : _loadResources,
                            icon: Icon(
                              Icons.refresh,
                              color: _isLoading ? Shared.gray : Shared.orange,
                              size: 28,
                            ),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ),

                    // Resources list
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _resources.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final resource = _resources[index];
                          return _buildResourceCard(resource);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildResourceCard(LocalResource resource) {
    final categoryColor = _getCategoryColor(resource.category);
    final categoryIcon = _getCategoryIcon(resource.category);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Shared.bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge and name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcon, size: 16, color: categoryColor),
                    const SizedBox(width: 6),
                    Text(
                      resource.category,
                      style: Shared.fontStyle(
                        16,
                        FontWeight.bold,
                        categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Name
          Text(
            resource.name,
            style: Shared.fontStyle(22, FontWeight.bold, Shared.black),
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            resource.description,
            style: Shared.fontStyle(18, FontWeight.w500, Shared.gray),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Address (clickable)
          InkWell(
            onTap: () => _launchMaps(resource.address),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 20, color: Shared.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      resource.address,
                      style: Shared.fontStyle(
                        16,
                        FontWeight.w500,
                        Shared.orange,
                      ),
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 16, color: Shared.orange),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Contact button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _launchContact(resource.contactInfo),
              style: ElevatedButton.styleFrom(
                backgroundColor: categoryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getContactIcon(resource.contactInfo), size: 20),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      resource.contactInfo,
                      style: Shared.fontStyle(
                        16,
                        FontWeight.bold,
                        Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
