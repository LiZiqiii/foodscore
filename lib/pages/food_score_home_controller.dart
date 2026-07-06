import 'package:flutter/material.dart';

/// FoodScore 首页控制器。
class FoodScoreHomeController {
  FoodScoreHomeController._();

  static const String brandName = 'FoodScore';
  static const String welcomeTitleLine1 = 'Ready to check';
  static const String welcomeTitleLine2 = 'your meal?';
  static const String welcomeSubtitle = 'Add a photo or describe your meal.';

  static const String ctaLabel = 'Analyse a meal';
  static const String reflectionTitle = 'Weekly Reflection';
  static const String reflectionSubtitle = 'Recent patterns and gentle focus';
  static const String disclaimerLine1 = 'Approximate meal-level feedback.';
  static const String disclaimerLine2 =
      'Not medical advice or precise nutrient calculation.';

  static const String mealImageAsset = 'assets/images/meal_bowl.png';

  static const List<HomeFeatureItem> features = [
    HomeFeatureItem(
      icon: Icons.photo_camera_outlined,
      label: 'Photo or text input',
    ),
    HomeFeatureItem(
      icon: Icons.bolt_outlined,
      label: 'Instant AI score',
    ),
    HomeFeatureItem(
      icon: Icons.tips_and_updates_outlined,
      label: 'Tips & explanations',
    ),
  ];

  // 颜色
  static const Color backgroundColor = Color(0xFFF8FAF5);
  static const Color welcomeGradientStart = Color(0xFFC8DECC);
  static const Color welcomeGradientEnd = Color(0xFFB2D0B8);
  static const Color welcomeTitleColor = Color(0xFF1A6731);
  static const Color welcomeSubtitleColor = Color(0xFF5E7262);
  static const Color featureTextColor = Color(0xFF9AA39A);
  static const Color featureIconColor = Color(0xFF8FB89A);
  static const Color featureIconBg = Color(0x108FB89A);
  static const Color ctaColor = Color(0xFF1A6731);
  static const Color brandColor = Color(0xFF1A6731);
  static const Color userAvatarBg = Color(0xFF1A6731);
  static const Color reflectionTitleColor = Color(0xFF4A4B48);
  static const Color reflectionSubtitleColor = Color(0xFF959694);
  static const Color reflectionBorderColor = Color(0xFFCDD8CD);
  static const Color reflectionArrowColor = Color(0xFFB8C0B8);
  static const Color disclaimerColor = Color(0xFF8A8C88);

  // 尺寸
  static const double horizontalPadding = 24;
  static const double topExtraPadding = 4;
  /// Hero 卡片及以下内容整体下移约 1.5 行。
  static const double heroContentTopGap = 24;
  static const double brandFontSize = 18;
  static const double brandTopInset = 10;
  static const double welcomeCardHeight = 128;
  static const double welcomeCardRadius = 16;
  static const double welcomeTitleFontSize = 22;
  static const double welcomeTitleLine2FontSize = 19;
  static const double welcomeSubtitleFontSize = 13;
  static const double welcomeMealImageWidth = 72;
  static const double welcomeToFeaturesGap = 20;
  static const double featuresToCtaGap = 32;
  static const double featureIconBoxSize = 26;
  static const double featureIconSize = 14;
  static const double featureFontSize = 13;
  static const double featureRowGap = 8;
  static const double ctaHeight = 48;
  static const double reflectionCardHeight = 62;
  static const double reflectionCardRadius = 12;
  static const double ctaToReflectionGap = 12;
  static const double reflectionToDisclaimerGap = 48;
  static const double disclaimerBottomPadding = 40;
}

/// 首页功能项。
class HomeFeatureItem {
  const HomeFeatureItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
