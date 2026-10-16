import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const purple = Color(0xFF7429C3);
  static const red = Color(0xFFEE0B2A);
  static const gold = Color(0xFFF6BA00);
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: purple).copyWith(
      primary: purple,
      secondary: red,
      surface: const Color(0xFFF7F3FC),
    ),
    scaffoldBackgroundColor: const Color(0xFFF7F3FC),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: purple,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 54),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
        color: Color(0xFF150B24),
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Color(0xFF150B24),
      ),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF615971)),
    ),
  );
}
