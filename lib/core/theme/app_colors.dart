import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary backgrounds
  static const Color backgroundPrimary = Color(0xFF0A1628);
  static const Color backgroundSecondary = Color(0xFF0F2027);
  static const Color backgroundTertiary = Color(0xFF121E2E);

  // Surface / Cards
  static const Color surface = Color(0xFF1A2A3A);
  static const Color surfaceLight = Color(0xFF243447);
  static const Color surfaceGlass = Color(0xCC1A2A3A); // 80% opacity

  // Accent
  static const Color gold = Color(0xFFD4A849);
  static const Color goldLight = Color(0xFFF5C842);
  static const Color goldDim = Color(0xFF8B7432);
  static const Color goldShimmer = Color(0xFFFFE08A);

  // Text
  static const Color textPrimary = Color(0xFFE8E0D4);
  static const Color textSecondary = Color(0xFF8A9BAE);
  static const Color textDim = Color(0xFF5A6A7A);
  static const Color textGold = Color(0xFFD4A849);

  // Semantic
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFB923C);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // Prayer-specific
  static const Color prayerOnTime = Color(0xFF34D399);
  static const Color prayerLate = Color(0xFFFB923C);
  static const Color prayerMissed = Color(0xFFF87171);
  static const Color prayerUpcoming = Color(0xFF3A4A5A);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A3045), Color(0xFF0A1628)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A849), Color(0xFFF5C842), Color(0xFFD4A849)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2A3A), Color(0xFF0F2027)],
  );

  static const LinearGradient scoreRingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5C842), Color(0xFFD4A849)],
  );
}
