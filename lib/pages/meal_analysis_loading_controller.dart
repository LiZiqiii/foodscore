import 'package:flutter/material.dart';

/// 餐食分析 Loading 页控制器。
class MealAnalysisLoadingController {
  MealAnalysisLoadingController._();

  static const String title = 'Analysing your meal...';
  static const String subtitle =
      'We\'re checking balance, variety, food quality and processing level.';
  static const String hint = 'This only takes a few seconds.';

  static const List<String> analysisSteps = [
    'Meal Balance',
    'Food Variety',
    'Whole Food Quality',
    'Processing Level',
  ];

  // 颜色
  static const Color backgroundStart = Color(0xFFF6FAF0);
  static const Color backgroundEnd = Color(0xFFEEF7F1);
  static const Color glowColor = Color(0xFF1A6731);
  static const Color titleColor = Color(0xFF1A6731);
  static const Color subtitleColor = Color(0xFF4A6B52);
  static const Color hintColor = Color(0xFF878984);
  static const Color cardColor = Color(0xE6FFFFFF);
  static const Color ringTrackColor = Color(0x331A6731);
  static const Color ringActiveColor = Color(0xFF1A6731);
  static const Color iconColor = Color(0xFF0F6B35);
  static const Color stepChipBg = Color(0xFFE1F4F0);
  static const Color stepChipText = Color(0xFF2E5E35);

  // 尺寸
  static const double horizontalPadding = 28;
  static const double cardRadius = 22;
  static const double cardPaddingH = 24;
  static const double cardPaddingV = 28;
  static const double ringSize = 58;
  static const double ringStroke = 2.8;
  static const double iconSize = 24;
  static const double titleFontSize = 18;
  static const double subtitleFontSize = 14;
  static const double hintFontSize = 13;
  static const double stepFontSize = 12;
  static const double cardToStepsGap = 22;
  static const double stepChipHeight = 28;
  static const Duration stepHighlightInterval = Duration(milliseconds: 1400);

  // 分析失败时的文案与按钮（不改变 Loading 主视觉，仅在出错时显示）
  static const String errorTitle = 'Analysis failed';
  static const String errorFallbackMessage =
      'Something went wrong while analysing your meal. Please try again.';
  static const String retryLabel = 'Retry';
  static const String useMockLabel = 'Use mock result';
  static const String backLabel = 'Back';
  static const Color errorTitleColor = Color(0xFF1A6731);
  static const Color errorMessageColor = Color(0xFF4A6B52);
  static const Color errorActionText = Color(0xFF1A6731);
}
