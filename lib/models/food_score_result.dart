/// 单个评分维度（GPT / FastAPI 返回的结构）。
class FoodScoreDimension {
  const FoodScoreDimension({
    required this.name,
    required this.description,
    required this.score,
    required this.label,
    required this.feedback,
  });

  factory FoodScoreDimension.fromJson(Map<String, dynamic> json) {
    return FoodScoreDimension(
      name: json['name'] as String,
      description: json['description'] as String,
      score: (json['score'] as num).toInt(),
      label: json['label'] as String,
      feedback: json['feedback'] as String,
    );
  }

  final String name;
  final String description;
  final int score;
  final String label;
  final String feedback;

  double get progress => score.clamp(1, 10) / 10;
  String get scoreText => '$score/10';
}

/// Score 页维度卡片适配。
class ResultDimension {
  const ResultDimension({
    required this.description,
    required this.score,
    required this.label,
  });

  final String description;
  final int score;
  final String label;

  double get progress => score / 10;
  String get scoreText => '$score/10';
}

/// Insight 页条目（title + description 均由 GPT 生成）。
class InsightItem {
  const InsightItem({
    required this.title,
    required this.description,
    required this.isPositive,
  });

  factory InsightItem.fromJson(
    Map<String, dynamic> json, {
    required bool isPositive,
  }) {
    return InsightItem(
      title: json['title'] as String,
      description: json['description'] as String,
      isPositive: isPositive,
    );
  }

  final String title;
  final String description;
  final bool isPositive;
}

/// AI 餐食分析结果（与 FastAPI `/analyse-text` JSON 对齐）。
class FoodScoreResult {
  const FoodScoreResult({
    required this.mealName,
    required this.overallScore,
    required this.overallLabel,
    required this.summary,
    required this.dimensions,
    required this.strengths,
    required this.concerns,
    required this.tips,
    required this.positiveNotes,
    required this.disclaimer,
  });

  factory FoodScoreResult.fromJson(Map<String, dynamic> json) {
    return FoodScoreResult(
      mealName: json['mealName'] as String,
      overallScore: (json['overallScore'] as num).toInt(),
      overallLabel: json['overallLabel'] as String,
      summary: json['summary'] as String,
      dimensions: (json['dimensions'] as List<dynamic>)
          .map((e) => FoodScoreDimension.fromJson(e as Map<String, dynamic>))
          .toList(),
      strengths: (json['strengths'] as List<dynamic>)
          .map(
            (e) => InsightItem.fromJson(
              e as Map<String, dynamic>,
              isPositive: true,
            ),
          )
          .toList(),
      concerns: (json['concerns'] as List<dynamic>)
          .map(
            (e) => InsightItem.fromJson(
              e as Map<String, dynamic>,
              isPositive: false,
            ),
          )
          .toList(),
      tips: json['tips'] as String,
      positiveNotes: (json['positiveNotes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      disclaimer: json['disclaimer'] as String,
    );
  }

  final String mealName;
  final int overallScore;
  final String overallLabel;
  final String summary;
  final List<FoodScoreDimension> dimensions;
  final List<InsightItem> strengths;
  final List<InsightItem> concerns;

  /// Tips 页白色文本框内的一段建议（GPT 生成）。
  final String tips;
  final List<String> positiveNotes;
  final String disclaimer;

  /// Score 页四维度进度条（feedback 作为卡片正文，高度随行数自适应）。
  List<ResultDimension> get scoreDimensions => dimensions
      .map(
        (d) => ResultDimension(
          description: d.feedback,
          score: d.score,
          label: d.label,
        ),
      )
      .toList();

  /// Tips 页 Hero 标题。
  String get tipsHeadline =>
      positiveNotes.isNotEmpty ? positiveNotes.first : '';

  /// Score 页展示用总分（GPT 仍为 1–10，展示为 1–100）。
  int get displayOverallScore => overallScore * 10;
}
