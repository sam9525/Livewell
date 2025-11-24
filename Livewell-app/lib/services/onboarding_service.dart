import 'package:firebase_auth/firebase_auth.dart';
import 'onboarding_constants.dart';

class OnboardingService {
  static Future<bool> hasCompletedOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;

    // If no user or no creation time, skip onboarding (existing user)
    if (user == null || user.metadata.creationTime == null) {
      return true;
    }

    final createdAt = user.metadata.creationTime!;
    final now = DateTime.now();
    final timeSinceCreation = now.difference(createdAt);

    // Show onboarding only if user was created recently
    return timeSinceCreation > OnboardingConstants.onboardingTimeThreshold;
  }
}
