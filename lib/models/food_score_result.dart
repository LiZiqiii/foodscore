import 'food_score_insight_item.dart';

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
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      feedback: json['feedback'] as String? ?? '',
    );
  }

  final String name;
  final String description;
  final int score;
  final String label;
  final String feedback;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'score': score,
        'label': label,
        'feedback': feedback,
      };

  double get progress => score.clamp(0, 10) / 10;
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

/// Parses the dimensions array; returns `[]` when missing or invalid.
List<FoodScoreDimension> parseFoodScoreDimensions(dynamic value) {
  if (value is! List) {
    return const [];
  }

  final dimensions = <FoodScoreDimension>[];
  for (final entry in value) {
    if (entry is Map<String, dynamic>) {
      dimensions.add(FoodScoreDimension.fromJson(entry));
    } else if (entry is Map) {
      dimensions.add(
        FoodScoreDimension.fromJson(Map<String, dynamic>.from(entry)),
      );
    }
  }
  return dimensions;
}

/// Returns a non-null string field from JSON; `''` when missing or invalid.
String parseFoodScoreStringField(dynamic value) {
  if (value is String) {
    return value;
  }
  return '';
}

/// AI 餐食分析结果（与 FastAPI `/analyse-text` JSON 对齐）。
class FoodScoreResult {
  const FoodScoreResult({
    required this.mealName,
    required this.overallScore,
    required this.overallLabel,
    required this.summary,
    required this.dimensions,
    required this.keyInsights,
    required this.mealTips,
    required this.disclaimer,
  });

  factory FoodScoreResult.fromJson(Map<String, dynamic> json) {
    final dimensions = parseFoodScoreDimensions(json['dimensions']);
    final overallScore = computeOverallScore(dimensions);
    final overallLabel = computeOverallLabel(overallScore);

    return FoodScoreResult(
      mealName: parseFoodScoreStringField(json['mealName']),
      overallScore: overallScore,
      overallLabel: overallLabel,
      summary: parseFoodScoreStringField(json['summary']),
      dimensions: dimensions,
      keyInsights: parseKeyInsights(json),
      mealTips: parseMealActionTips(json),
      disclaimer: parseFoodScoreStringField(json['disclaimer']),
    );
  }

  final String mealName;
  final int overallScore;
  final String overallLabel;
  final String summary;
  final List<FoodScoreDimension> dimensions;
  final List<FoodScoreInsightItem> keyInsights;

  /// Tips 页 1–2 条可执行建议（GPT 生成，`tips.tips`）。
  final List<String> mealTips;
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

  /// 四维度 0–10 均值得出 0–100 总分（与后端一致）。
  static int computeOverallScore(List<FoodScoreDimension> dimensions) {
    if (dimensions.isEmpty) {
      return 0;
    }
    final total = dimensions.fold<int>(0, (sum, d) => sum + d.score);
    final average = total / dimensions.length;
    return (average * 10).round();
  }

  /// 0–100 总分对应的展示标签（与后端一致）。
  static String computeOverallLabel(int overallScore) {
    if (overallScore >= 85) {
      return 'Excellent';
    }
    if (overallScore >= 70) {
      return 'Good';
    }
    if (overallScore >= 50) {
      return 'Fair';
    }
    return 'Could be improved';
  }

  /// Score / Overview 页展示用总分（0–100）。
  int get displayOverallScore => overallScore;

  /// Serialises for FastAPI `/meal-records` and related endpoints.
  Map<String, dynamic> toJson() => {
        'mealName': mealName,
        'overallScore': overallScore,
        'overallLabel': overallLabel,
        'summary': summary,
        'dimensions': dimensions.map((dimension) => dimension.toJson()).toList(),
        'insight': {
          'keyInsights': keyInsights.map((item) => item.toJson()).toList(),
        },
        'tips': {
          'tips': mealTips,
        },
        'disclaimer': disclaimer,
      };
}
