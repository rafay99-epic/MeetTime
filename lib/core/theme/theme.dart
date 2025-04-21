import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primarySwatch: Colors.indigo,
    primaryColor: Colors.indigo[500],
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(
      secondary: Colors.amber,
      surface: Colors.white,
      onSurface: Colors.black87,
      onPrimary: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
  );
}
