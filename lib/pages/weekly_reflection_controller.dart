import 'package:flutter/material.dart';

/// Weekly Reflection 页文案与样式。
class WeeklyReflectionController {
  WeeklyReflectionController._();

  static const String title = 'Weekly Reflection';

  static const String emptyTitle = 'No weekly reflection yet';
  static const String emptySubtitle =
      'Save a few meals to see your recent patterns here.';
  static const String emptyCtaLabel = 'Analyse a meal';

  static const String recentMealsTitle = 'Records';
  static const String weeklySummaryTitle = 'This week';
  static const String goodPatternsTitle = 'What went well';
  static const String smallFocusTitle = 'Gentle focus';
  static const String summaryLoadingLabel = 'Preparing your weekly summary…';

  static const Color backgroundColor = Color(0xFFF8FAF5);
  static const Color backColor = Color(0xFF1A6731);
  static const Color titleColor = Color(0xFF4A4B48);
  static const Color subtitleColor = Color(0xFF878984);
  static const Color emptyTitleColor = Color(0xFF4A4B48);
  static const Color emptySubtitleColor = Color(0xFF878984);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE1EDE6);
  static const Color cardMetaColor = Color(0xFF8A8C88);
  static const Color statusColor = Color(0xFF9AA39A);
  static const Color sectionTitleColor = Color(0xFF4A4B48);
  static const Color summaryCardBg = Color(0xFFF0F7F2);
  static const Color tagBg = Color(0xFFE1F4F0);
  static const Color tagText = Color(0xFF3D6C47);
  static const Color ctaColor = Color(0xFF1A6731);

  static const double horizontalPadding = 24;
  static const double ctaHeight = 48;

  // Meal record cards (Records section)
  static const double mealCardRadius = 16;
  static const double mealCardPaddingH = 14;
  static const double mealCardPaddingV = 11;
  static const double mealCardTitleFontSize = 15;
  static const double mealCardMetaFontSize = 12;
  static const double mealCardStatusFontSize = 10;
  static const double mealCardTitleToMetaGap = 5;
  static const double mealCardMetaToTagsGap = 8;
  static const double mealCardTagsToStatusGap = 8;
  static const double mealCardGap = 10;
  static const double tagChipPaddingH = 7;
  static const double tagChipPaddingV = 3;
  static const double tagChipFontSize = 10;
  static const double tagChipSpacing = 5;
}
