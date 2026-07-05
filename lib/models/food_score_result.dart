/// 单个维度的 AI 生成内容（顺序对应 [ResultPageController.dimensionTemplates]）。
class ResultDimension {
  const ResultDimension({
    required this.description,
    required this.score,
    required this.label,
  });

  /// AI 生成的维度说明。
  final String description;

  /// AI 生成的分数（1–10）。
  final int score;

  /// AI 生成的简短评价标签，如 "Good"。
  final String label;

  double get progress => score / 10;
  String get scoreText => '$score/10';
}

/// Insight 条目（优点或关注点，均由 AI 生成）。
class InsightItem {
  const InsightItem({
    required this.title,
    required this.description,
    required this.isPositive,
  });

  final String title;
  final String description;
  final bool isPositive;
}

/// 改进建议（AI 生成）。
class ImprovementTip {
  const ImprovementTip({required this.text});

  final String text;
}

/// AI 餐食分析结果。
///
/// **来自大模型的字段：** [overallScore]、[overallLabel]、[mealName]、[summary]、
/// [dimensions]、[strengths]、[concerns]、[tips]、[tipsHeadline]。
///
/// **固定 UI（不在此模型）：** Tab 名称、维度名称/icon、区块标题、免责声明文案等，
/// 见 ResultPageController。
class FoodScoreResult {
  const FoodScoreResult({
    required this.overallScore,
    required this.overallLabel,
    required this.mealName,
    required this.summary,
    required this.dimensions,
    required this.strengths,
    required this.concerns,
    required this.tips,
    required this.tipsHeadline,
  });

  final int overallScore;
  final String overallLabel;
  final String mealName;
  final String summary;

  /// 固定 4 项，顺序与 dimensionTemplates 一致。
  final List<ResultDimension> dimensions;
  final List<InsightItem> strengths;
  final List<InsightItem> concerns;
  final List<ImprovementTip> tips;
  final String tipsHeadline;
}
