import 'package:flutter/material.dart';
import 'shared/shared.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveWell',
      theme: ThemeData(scaffoldBackgroundColor: Shared.bgColor),
      home: const MyHomePage(),
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
              onPressed: () {},
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
              onPressed: () {},
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
