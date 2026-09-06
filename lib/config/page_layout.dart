import 'package:flutter/material.dart';

import '../widgets/meal_feedback_disclaimer.dart';

abstract final class PageLayout {
  static const String backLabel = '<  Back';
  static const Color backColor = Color(0xFF1A6731);
  static const double horizontalPadding = 24;
  static const double topExtraPadding = 10;
  static const double backToTitleGap = 18;
  static const double primaryButtonHeight = 48;
  static const double primaryButtonRadius = 15;

  /// Meal-feedback disclaimer inset above home indicator (shared widget).
  static const double disclaimerBottomInset =
      MealFeedbackDisclaimerCopy.bottomInset;
}
/// Title + subtitle styling for choose / text upload / photo upload pages.
abstract final class MealFlowPageStyle {
  static const double titleFontSize = 24;
  static const double subtitleFontSize = 13;
  static const double titleToSubtitleGap = 14;
  static const Color titleColor = Color(0xB3000000);
  static const Color subtitleColor = Color(0x99000000);
  static const double titleLineHeight = 1.25;
  static const double subtitleLineHeight = 1.35;
}
