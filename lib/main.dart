import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/results.dart';
import 'screens/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Planner',
      debugShowCheckedModeBanner: false,

      // Routes for navigation
      routes: {
        '/': (context) => const HomeScreen(),
        '/results': (context) => const ResultsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },

      initialRoute: '/',
    );
  }
}
