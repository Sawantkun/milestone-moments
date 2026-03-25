import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF7B61FF);
  static const Color primaryLight = Color(0xFF9E8FFF);
  static const Color primaryDark = Color(0xFF5A3FE0);

  // Accent palette
  static const Color pink = Color(0xFFFF6B9D);
  static const Color pinkLight = Color(0xFFFF90B8);
  static const Color pinkDark = Color(0xFFE5457A);

  // Teal
  static const Color teal = Color(0xFF00BFA5);
  static const Color tealLight = Color(0xFF33CDB8);
  static const Color tealDark = Color(0xFF009B84);

  // Neutral backgrounds
  static const Color backgroundLight = Color(0xFFF8F4FF);
  static const Color backgroundDark = Color(0xFF12101A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1A2E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF252038);

  // Text colours
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF1EEFF);
  static const Color textSecondaryDark = Color(0xFFA89FBF);

  // Divider / border
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF2E2A45);

  // Category colours
  static const Color motorColor = Color(0xFF4CAF50);
  static const Color languageColor = Color(0xFFFF9800);
  static const Color socialColor = Color(0xFFE91E63);
  static const Color cognitiveColor = Color(0xFF2196F3);
  static const Color otherColor = Color(0xFF9C27B0);

  // Mood colours
  static const Color moodAwful = Color(0xFFEF5350);
  static const Color moodSad = Color(0xFFFF7043);
  static const Color moodOkay = Color(0xFFFFCA28);
  static const Color moodGood = Color(0xFF66BB6A);
  static const Color moodGreat = Color(0xFF26C6DA);

  // Chart colours
  static const Color chartBlue = Color(0xFF42A5F5);
  static const Color chartGreen = Color(0xFF66BB6A);
  static const Color chartPurple = Color(0xFFAB47BC);
  static const Color chartOrange = Color(0xFFFFA726);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, pink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleTeal = LinearGradient(
    colors: [primary, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkOrange = LinearGradient(
    colors: [pink, Color(0xFFFFB347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onboardingPage1 = LinearGradient(
    colors: [Color(0xFF7B61FF), Color(0xFFB088FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient onboardingPage2 = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF9DC6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient onboardingPage3 = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF4DD9C7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient onboardingPage4 = LinearGradient(
    colors: [Color(0xFF5A3FE0), Color(0xFF7B61FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
