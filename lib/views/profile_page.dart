import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livewell_app/auth/sign_out.dart';
import 'package:provider/provider.dart';
import '../shared/shared.dart';
import '../shared/user_provider.dart';
import '../auth/profile_auth.dart';
import '../shared/location_provider.dart';
import 'frailty_survey_page.dart';
import 'interactive_onboarding.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    _initProfile();
  }

  void _initProfile() async {
    await ProfileAuth.getProfile();
    // Trigger a rebuild after profile data is loaded
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, LocationProvider>(
      builder: (context, userProvider, locationProvider, child) {
        final user = userProvider.user;

        Widget buildProfileField(String label, String value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                textAlign: TextAlign.left,
                style: Shared.fontStyle(28, FontWeight.bold, Shared.black),
              ),
              Shared.inputContainer(
                double.infinity,
                value,
                null,
                fontColor: Shared.darkGray,
                enabled: false,
              ),
              const SizedBox(height: 15),
            ],
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: Shared.orange.withValues(alpha: 0.1),
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Icon(Icons.person, size: 75, color: Shared.orange)
                          : null,
                    ),
                    const SizedBox(height: 20),
                    buildProfileField('Name', user?.displayName ?? 'User'),
                    buildProfileField(
                      'Email',
                      user?.email ?? 'No email available',
                    ),
                    buildProfileField(
                      'Gender',
                      UserProvider.userGender ?? 'No gender available',
                    ),
                    buildProfileField(
                      'Age Range',
                      UserProvider.userAgeRange ?? 'No age range available',
                    ),
                    buildProfileField(
                      'Suburb',
                      locationProvider.suburbWithPostcode,
                    ),
                    OnboardingTarget(
                      targetKey: 'frailty_button',
                      child: _buildFrailtyButton(),
                    ),
                  ],
                ),
              ),
              if (userProvider.isSignedIn) _buildSignOutButton(context),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSignOutButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => SignOut.showSignOutDialog(context),
          style: Shared.buttonStyle(
            MediaQuery.of(context).size.width,
            52,
            Shared.orange,
            Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/logout.svg',
                height: 30,
                width: 30,
                colorFilter: ColorFilter.mode(Shared.bgColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 10),
              Text(
                'Sign Out',
                style: Shared.fontStyle(24, FontWeight.bold, Shared.bgColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildFrailtyButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FrailtySurveyPage(),
                  ),
                );
              },
              style: Shared.buttonStyle(
                double.infinity,
                52,
                Shared.orange,
                Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Frailty Assessment',
                    style: Shared.fontStyle(
                      24,
                      FontWeight.bold,
                      Shared.bgColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Use Provider to get the frailty score (default to 1 if null)
                  Builder(
                    builder: (context) {
                      final frailtyScore = UserProvider.userFrailtyScore ?? 0.0;
                      String? iconPath;
                      if (frailtyScore == 0) {
                        iconPath = null;
                      } else if (frailtyScore < 1.5) {
                        iconPath = 'assets/icons/happy.svg';
                      } else if (frailtyScore < 2.5) {
                        iconPath = 'assets/icons/neutral.svg';
                      } else {
                        iconPath = 'assets/icons/sad.svg';
                      }
                      return iconPath != null
                          ? SvgPicture.asset(iconPath, height: 30, width: 30)
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
