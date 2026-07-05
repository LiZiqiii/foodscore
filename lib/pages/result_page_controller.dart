import 'package:flutter/material.dart';

/// 固定维度模板（名称 + icon，不来自 AI）。
class ResultDimensionTemplate {
  const ResultDimensionTemplate({
    required this.name,
    required this.emoji,
  });

  final String name;
  final String emoji;
}

/// Result 页样式与固定 UI 文案。
class ResultPageController {
  ResultPageController._();

  // ---------------------------------------------------------------------------
  // 固定 Tab / 区块标题（UI 标签，不来自 AI）
  // ---------------------------------------------------------------------------

  static const List<String> tabLabels = ['Score', 'Insight', 'Tips'];

  static const String foodQualityScoreLabel = 'FOOD QUALITY SCORE';
  static const String outOf10Label = 'OUT OF 10';
  static const String scoreBreakdownTitle = 'SCORE BREAKDOWN';
  static const String analysedMealLabel = 'ANALYSED MEAL';
  static const String doesWellSectionTitle = 'WHAT THIS MEAL DOES WELL';
  static const String concernSectionTitle = 'AREAS OF CONCERN';
  static const String nextTimeTryLabel = 'NEXT TIME, TRY';
  static const String notePrefix = 'Note:';
  static const String rememberPrefix = 'Remember:';
  static const String gotItLabel = 'Got it';

  /// 四个维度名称与 icon 固定；分数与描述由 AI 填入。
  static const List<ResultDimensionTemplate> dimensionTemplates = [
    ResultDimensionTemplate(name: 'Meal Balance', emoji: '⚖️'),
    ResultDimensionTemplate(name: 'Food Variety', emoji: '🎨'),
    ResultDimensionTemplate(name: 'Whole Food Quality', emoji: '🍃'),
    ResultDimensionTemplate(name: 'Processing & Concerns', emoji: '⚠️'),
  ];

  static const String scoreDisclaimer =
      'FoodScore provides an approximate food quality assessment based on visible or described food items only. It is not a medical tool or precise nutritional analysis.';

  static const String tipsDisclaimer =
      'These are general suggestions based on typical food quality principles. Every person\'s needs differ. FoodScore is not medical or dietary advice.';

  // ---------------------------------------------------------------------------
  // 颜色
  // ---------------------------------------------------------------------------

  static const Color backgroundColor = Color(0xFFF6FAF0);
  static const Color tabBarBg = Color(0xFFF2F2F2);
  static const Color tabActiveBg = Color(0xFF165529);
  static const Color tabInactiveText = Color(0xFF909090);
  static const Color tabActiveText = Colors.white;
  static const Color heroGreenSolid = Color(0xFF165529);
  static const Color heroLabel = Color(0xFFF0FFD9);
  static const Color scoreAccent = Color(0xFF7EDCA9);
  static const Color scoreBarGood = Color(0xFF65B087);
  static const Color scoreBarFair = Color(0xFFEBA26F);
  static const Color scoreCircle = Color(0xFFC9A06C);
  static const Color sectionTitle = Color(0x73000000);
  static const Color cardTitle = Color(0xAB000000);
  static const Color cardBody = Color(0xAB767676);
  static const Color disclaimerBg = Color(0xBFE4F8F3);
  static const Color disclaimerText = Color(0xCC165529);
  static const Color gotItBorder = Color(0xF2165529);
  static const Color gotItText = Color(0xF2165529);

  // ---------------------------------------------------------------------------
  // 尺寸
  // ---------------------------------------------------------------------------

  static const double horizontalPadding = 27;
  static const double tabBarHeight = 33;
  static const double tabBarRadius = 15;
  static const double heroRadius = 20;
  static const double cardRadius = 20;
  static const double insightCardRadius = 15;

  /// SafeArea 之外额外下移，避免 Tab 贴顶；SafeArea 本身会避开刘海/状态栏。
  static const double topExtraPadding = 28;

  /// Insight 页固定餐食 icon（与首页 meal_bowl 区分）。
  static const String insightMealImageAsset =
      'assets/images/insight_salad_bowl.png';

  /// 1–5 橙色，6–10 绿色。
  static Color scoreColor(int score) {
    final clamped = score.clamp(1, 10);
    return clamped <= 5 ? scoreBarFair : scoreBarGood;
  }

  static ResultDimensionTemplate templateAt(int index) {
    return dimensionTemplates[index];
  }
}
