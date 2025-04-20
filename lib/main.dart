import 'package:flutter/material.dart';
import 'package:meettime/core/theme/theme.dart';
import 'package:meettime/features/splashscreen/splashscreen.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
