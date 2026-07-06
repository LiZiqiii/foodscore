import 'package:flutter/material.dart';

/// Weekly Reflection 页文案与样式。
class WeeklyReflectionController {
  WeeklyReflectionController._();

  static const String backLabel = '<  Back';
  static const String title = 'Weekly Reflection';

  static const String emptyTitle = 'No weekly reflection yet';
  static const String emptySubtitle =
      'Save a few meals to see your recent patterns here.';
  static const String emptyCtaLabel = 'Analyse a meal';

  static const String savedMealsHeading = 'Recent saved meals';
  static const String photoMealLabel = 'Meal photo';

  static const Color backgroundColor = Color(0xFFF6FAF0);
  static const Color backColor = Color(0xFF1A6731);
  static const Color titleColor = Color(0xFF4A4B48);
  static const Color emptyTitleColor = Color(0xFF4A4B48);
  static const Color emptySubtitleColor = Color(0xFF878984);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE1EDE6);
  static const Color cardMetaColor = Color(0xFF8A8C88);
  static const Color ctaColor = Color(0xFF1A6731);

  static const double horizontalPadding = 24;
  static const double topExtraPadding = 10;
  static const double backToTitleGap = 18;
  static const double ctaHeight = 48;
  static const double ctaRadius = 15;
}
