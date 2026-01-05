import 'package:firebase_auth/firebase_auth.dart';
import 'package:livewell_app/shared/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'onboarding_constants.dart';

class OnboardingService {
  static Future<bool> hasCompletedOnboarding() async {
    final isEmail = UserProvider.instance?.isEmailSignedIn == true;
    final user = isEmail
        ? FirebaseAuth.instance.currentUser
        : Supabase.instance.client.auth.currentUser;

    final creationTime = isEmail
        ? (user as dynamic)?.metadata.creationTime
        : DateTime.tryParse((user as dynamic)?.createdAt ?? '');

    // If no user or no creation time, skip onboarding (existing user)
    if (user == null || creationTime == null) {
      return true;
    }

    final createdAt = creationTime;
    final now = DateTime.now();
    final timeSinceCreation = now.difference(createdAt);

    // Show onboarding only if user was created recently
    return timeSinceCreation > OnboardingConstants.onboardingTimeThreshold;
  }
}
