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
  static const String outOf100Label = 'OUT OF 100';
  static const String scoreBreakdownTitle = 'SCORE BREAKDOWN';
  static const String dimensionDetailsShow = 'Details';
  static const String dimensionDetailsHide = 'Hide';
  static const String analysedMealLabel = 'ANALYSED MEAL';
  static const String keyInsightsSectionTitle = 'KEY INSIGHTS';
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

  // Score 页 — 分数说明 bottom sheet（固定文案）
  static const String scoreExplanationLinkLabel = 'What do these scores mean?';
  static const String scoreExplanationTitle = 'What do these scores mean?';
  static const String scoreExplanationSubtitle =
      'FoodScore estimates meal quality using four simple dimensions.';
  static const String scoreExplanationIntro =
      'The overall score is based on the meal information provided, such as the photo and any optional text details.';
  static const String scoreExplanationFooterDisclaimer =
      'This score is an approximate food quality indicator, not a precise nutrient calculation or medical advice.';
  static const List<ScoreExplanationDimension> scoreExplanationDimensions = [
    ScoreExplanationDimension(
      title: 'Meal Balance',
      explanation:
          'Checks whether the meal includes key food groups, such as carbohydrates, protein, vegetables or fruit.',
    ),
    ScoreExplanationDimension(
      title: 'Food Variety',
      explanation:
          'Checks the diversity of food groups, colours and ingredients in the meal.',
    ),
    ScoreExplanationDimension(
      title: 'Whole Food Quality',
      explanation:
          'Checks whether the meal is mainly based on whole or minimally processed foods.',
    ),
    ScoreExplanationDimension(
      title: 'Processing & Concerns',
      explanation:
          'Checks visible or described concerns, such as fried, sugary, salty, or highly processed foods.',
    ),
  ];

  static const Color scoreExplanationLinkColor = Color(0xFF4A6B52);
  static const Color scoreExplanationSubtitleColor = Color(0xFF878984);
  static const Color scoreExplanationFooterColor = Color(0xFF959694);
  static const double scoreExplanationSheetHeightFactor = 0.8;

  // ---------------------------------------------------------------------------
  // 颜色
  // ---------------------------------------------------------------------------

  static const Color backgroundColor = Color(0xFFF8FAF5);
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
  static const double insightCardTitleFontSize = 15;

  /// SafeArea 之外额外下移，避免 Tab 贴顶；SafeArea 本身会避开刘海/状态栏。
  static const double topExtraPadding = 10;

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

  /// 固定维度完整定义（name + description），供 mock / GPT schema 对齐。
  static FoodScoreDimensionDefinition definitionAt(int index) {
    final template = dimensionTemplates[index];
    return FoodScoreDimensionDefinition(
      name: template.name,
      description: _dimensionDescriptions[index],
      emoji: template.emoji,
    );
  }

  static const List<String> _dimensionDescriptions = [
    'Protein, carbs, fats and vegetables.',
    'Different food groups, colours and ingredients.',
    'Fresh, whole and minimally processed foods.',
    'Added sugar, salt, sauces or ultra-processed items.',
  ];
}

/// 分数说明 sheet 中的维度卡片文案。
class ScoreExplanationDimension {
  const ScoreExplanationDimension({
    required this.title,
    required this.explanation,
  });

  final String title;
  final String explanation;
}

/// 固定维度定义（name + description + emoji）。
class FoodScoreDimensionDefinition {
  const FoodScoreDimensionDefinition({
    required this.name,
    required this.description,
    required this.emoji,
  });

  final String name;
  final String description;
  final String emoji;
}
