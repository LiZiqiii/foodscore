import 'package:flutter/material.dart';

/// FoodScore 首页控制器。
class FoodScoreHomeController {
  FoodScoreHomeController._();

  static const String brandName = 'FoodScore';
  static const String headlineLine1 = 'Understand your';
  static const String headlineLine2 = 'meal quality,';
  static const String headlineLine3 = 'simply.';

  static const String description =
      'Upload a photo or describe your meal to receive a simple score, explanation, and practical tips.';

  static const String ctaLabel = 'Analyse a meal';
  static const String disclaimerLine1 = 'Approximate meal-level feedback.';
  static const String disclaimerLine2 =
      'Not medical advice or precise nutrient calculation.';

  static const String mealImageAsset = 'assets/images/meal_bowl.png';

  static const List<HomeFeatureItem> features = [
    HomeFeatureItem(
      icon: Icons.photo_camera_outlined,
      label: 'Photo or text meal input',
    ),
    HomeFeatureItem(
      icon: Icons.bolt_outlined,
      label: 'AI quality score in seconds',
    ),
    HomeFeatureItem(
      icon: Icons.tips_and_updates_outlined,
      label: 'Explanations & improvement tips',
    ),
  ];

  // 颜色
  static const Color backgroundColor = Color(0xFFF8FAF5);
  static const Color heroGradientStart = Color(0xFFB8D4BC);
  static const Color heroGradientEnd = Color(0xFF9EC4A4);
  static const Color brandColor = Color(0xFF1A6731);
  static const Color headlineColor = Colors.white;
  static const Color descriptionColor = Color(0xFF5E605C);
  static const Color featureTextColor = Color(0xFF3D403C);
  static const Color featureIconColor = Color(0xFF2E7D4E);
  static const Color featureIconBg = Color(0x1A2E7D4E);
  static const Color ctaColor = Color(0xFF1A6731);
  static const Color disclaimerColor = Color(0xFF8A8C88);

  // 尺寸
  static const double horizontalPadding = 24;
  static const double topExtraPadding = 40;
  static const double heroHeight = 248;
  static const double heroRadius = 20;
  static const double headlineFontSize = 30;
  static const double mealImageWidth = 200;
  static const double ctaHeight = 48;
  static const double ctaMaxWidth = 280;

  static const double ctaToDisclaimerGap = 26;
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
