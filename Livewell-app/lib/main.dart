import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:livewell_app/views/navigation.dart';
import 'package:provider/provider.dart';
import 'shared/shared.dart';
import 'shared/user_provider.dart';
import 'shared/date_provider.dart';
import 'views/signin.dart';
import 'views/signup.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'shared/goal_provider.dart';
import 'shared/location_provider.dart';
import 'shared/medication_provider.dart';
import 'shared/vaccination_provider.dart';
import 'auth/backend_auth.dart';
import 'services/fcm_service.dart';
import 'services/notifications_service.dart';
import 'config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseApiUrl,
    anonKey: EnvConfig.supabasePublishableKey,
  );

  // Initialize local notifications
  await NotificationService.initialize();

  // Initialize Firebase Cloud Messaging and register device token
  await FCMService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (context) => DateProvider()),
        ChangeNotifierProvider(create: (context) => WaterIntakeNotifier()),
        ChangeNotifierProvider(
          create: (context) =>
              CurrentWaterIntakeNotifier(context.read<WaterIntakeNotifier>()),
        ),
        ChangeNotifierProvider(create: (context) => StepsNotifier()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              CurrentStepsNotifier(context.read<StepsNotifier>()),
        ),
        ChangeNotifierProvider(create: (context) => MedicationProvider()),
        ChangeNotifierProvider(create: (context) => VaccinationProvider()),
      ],
      child: MaterialApp(
        title: 'LiveWell',
        theme: ThemeData(scaffoldBackgroundColor: Shared.bgColor),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static const buttonWidth = 160.0;
  static const buttonHeight = 52.0;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    // Check if the token is valid
    isTokenValid();
  }

  // Check if the jwt token is valid
  void isTokenValid() async {
    final isValid = await BackendAuth.isStoredTokenValid();

    // If the token is valid, navigate to the home page
    if (isValid) {
      // Authenticate with the stored jwt token to start refreshing the jwt token
      await BackendAuth.authenticateWithStoredToken();

      BackendAuth.startTokenRefreshTimer();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'LiveWell',
              style: Shared.fontStyle(40, FontWeight.bold, Shared.orange),
            ),
            SizedBox(height: 35),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
              style: Shared.buttonStyle(
                MyHomePage.buttonWidth,
                MyHomePage.buttonHeight,
                Shared.orange,
                Colors.white,
              ),
              child: Text(
                'Sign In',
                style: Shared.fontStyle(24, FontWeight.bold, Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              style: Shared.buttonStyle(
                MyHomePage.buttonWidth,
                MyHomePage.buttonHeight,
                Colors.white,
                Shared.orange,
              ),
              child: Text(
                'Sign Up',
                style: Shared.fontStyle(24, FontWeight.bold, Shared.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
