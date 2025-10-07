import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livewell_app/auth/sign_out.dart';
import 'package:provider/provider.dart';
import '../shared/shared.dart';
import '../shared/user_provider.dart';
import '../auth/profile_auth.dart';
import '../shared/location_provider.dart';

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
                    buildProfileField('Postcode', locationProvider.postcode),
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
}
