import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://eiedyvkypizrdsrqtggc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVpZWR5dmt5cGl6cmRzcnF0Z2djIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU0NDAzMjQsImV4cCI6MjA3MTAxNjMyNH0.AHMZLkd98iSQ2EeIfERgA6Us-VsE9QtsLAaa9gHtK1w',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => DateProvider()),
        ChangeNotifierProvider(create: (context) => WaterIntakeNotifier()),
        ChangeNotifierProvider(
          create: (context) =>
              CurrentWaterIntakeNotifier(context.read<WaterIntakeNotifier>()),
        ),
        ChangeNotifierProvider(create: (context) => StepsNotifier()),
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
