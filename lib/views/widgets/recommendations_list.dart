import 'package:flutter/material.dart';
import 'package:livewell_app/shared/shared_preferences_provider.dart';
import '../../shared/shared.dart';
import '../../model/recommendation_model.dart';
import '../../services/recommendation_service.dart';
import '../../services/notifications_service.dart';
import '../../auth/tracking_auth.dart';

class RecommendationsList extends StatefulWidget {
  const RecommendationsList({super.key});

  @override
  State<RecommendationsList> createState() => _RecommendationsListState();
}

class _RecommendationsListState extends State<RecommendationsList> {
  final RecommendationService _recommendationService = RecommendationService();
  List<Recommendation> _recommendations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);
    try {
      final recommendations = await _recommendationService
          .getAllRecommendations();
      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setGoals(Recommendation recommendation) async {
    try {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      final prefs = await SharedPreferencesProvider.getBackgroundPrefs();
      // Call the existing function to update goals
      final success = await TrackingAuth.putTodayTrackingTargets(
        recommendation.stepsTarget,
        recommendation.waterIntakeTarget == 0
            ? prefs?.getInt('target_water_intake') ?? 0
            : recommendation.waterIntakeTarget,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        // Mark recommendation as accepted in backend
        await _recommendationService.acceptRecommendation(recommendation.id);

        // Update local state
        setState(() {
          final index = _recommendations.indexWhere(
            (r) => r.id == recommendation.id,
          );
          if (index != -1) {
            _recommendations[index] = _recommendations[index].copyWith(
              isCompleted: true,
            );
          }
        });

        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Goals updated successfully!',
              style: Shared.fontStyle(16, FontWeight.w500, Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to update goals');
      }
    } catch (e) {
      debugPrint('Error setting goals: $e');
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog if still open

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update goals. Please try again.',
            style: Shared.fontStyle(16, FontWeight.w500, Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendFirstRecommendationNotification() async {
    try {
      if (_recommendations.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No recommendations available',
              style: Shared.fontStyle(16, FontWeight.w500, Colors.white),
            ),
            backgroundColor: Shared.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      final firstRecommendation = _recommendations.first;

      await NotificationService.showCustomRecommendationNotification(
        title: firstRecommendation.title,
        message: firstRecommendation.message,
        stepsTarget: firstRecommendation.stepsTarget,
        waterIntakeTarget: firstRecommendation.waterIntakeTarget,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notification sent!',
            style: Shared.fontStyle(16, FontWeight.w500, Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error sending notification: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send notification',
            style: Shared.fontStyle(16, FontWeight.w500, Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show widget if no recommendations
    if (_recommendations.isEmpty && !_isLoading) {
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
                          Icons.tips_and_updates,
                          color: Shared.orange,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'AI Health Recommendations',
                          style: Shared.fontStyle(
                            24,
                            FontWeight.bold,
                            Shared.black,
                          ),
                        ),
                      ),
                      // Notification button
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : _sendFirstRecommendationNotification,
                        icon: Icon(
                          Icons.notifications_active,
                          color: _isLoading ? Shared.gray : Shared.orange,
                          size: 28,
                        ),
                        tooltip: 'Send notification',
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ),

                // Loading state
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),

                // Recommendations list
                if (!_isLoading)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _recommendations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final recommendation = _recommendations[index];
                      return _buildRecommendationCard(recommendation);
                    },
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecommendationCard(Recommendation recommendation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Shared.bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: recommendation.isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : Shared.orange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            recommendation.title,
            style: Shared.fontStyle(18, FontWeight.bold, Shared.black),
          ),

          const SizedBox(height: 10),

          // Message with status indicator
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  recommendation.message,
                  style: Shared.fontStyle(16, FontWeight.w500, Shared.black),
                ),
              ),
              if (recommendation.isCompleted) ...[
                const SizedBox(width: 10),
                Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ],
          ),

          const SizedBox(height: 20),

          // Goals display
          Row(
            children: [
              // Steps Goal
              if (recommendation.stepsTarget > 0) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.directions_walk,
                          color: Colors.blue,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Daily Steps',
                          style: Shared.fontStyle(
                            14,
                            FontWeight.w500,
                            Shared.gray,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${recommendation.stepsTarget}',
                          style: Shared.fontStyle(
                            20,
                            FontWeight.bold,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
              ],

              if (recommendation.waterIntakeTarget > 0) ...[
                // Water Intake Goal
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.water_drop, color: Colors.cyan, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Water Intake',
                          style: Shared.fontStyle(
                            14,
                            FontWeight.w500,
                            Shared.gray,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${recommendation.waterIntakeTarget} ml',
                          style: Shared.fontStyle(
                            20,
                            FontWeight.bold,
                            Colors.cyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (recommendation.stepsTarget > 0 ||
              recommendation.waterIntakeTarget > 0) ...[
            const SizedBox(height: 20),

            // Set Goals Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: recommendation.isCompleted
                    ? null
                    : () => _setGoals(recommendation),
                style: ElevatedButton.styleFrom(
                  backgroundColor: recommendation.isCompleted
                      ? Shared.lightGray
                      : Shared.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Shared.lightGray,
                  disabledForegroundColor: Shared.gray,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: recommendation.isCompleted ? 0 : 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      recommendation.isCompleted
                          ? Icons.check
                          : Icons.rocket_launch,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      recommendation.isCompleted
                          ? 'Goals Applied ✓'
                          : 'Set Goals',
                      style: Shared.fontStyle(
                        18,
                        FontWeight.bold,
                        recommendation.isCompleted ? Shared.gray : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
