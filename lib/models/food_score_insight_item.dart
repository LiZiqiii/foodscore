/// A single insight entry (title + description) for meal analysis groups.
class FoodScoreInsightItem {
  const FoodScoreInsightItem({
    required this.title,
    required this.description,
  });

  factory FoodScoreInsightItem.fromJson(Map<String, dynamic> json) {
    return FoodScoreInsightItem(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  final String title;
  final String description;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };
}

/// Parses a JSON array of insight items; returns `[]` when missing or invalid.
List<FoodScoreInsightItem> parseFoodScoreInsightList(dynamic value) {
  if (value is! List) {
    return const [];
  }

  final items = <FoodScoreInsightItem>[];
  for (final entry in value) {
    Map<String, dynamic>? map;
    if (entry is Map<String, dynamic>) {
      map = entry;
    } else if (entry is Map) {
      map = Map<String, dynamic>.from(entry);
    }
    if (map == null) {
      continue;
    }
    final title = map['title'];
    final description = map['description'];
    if (title is String && description is String) {
      items.add(
        FoodScoreInsightItem(title: title, description: description),
      );
    }
  }
  return items;
}

/// Parses meal action tips from nested `tips.tips` or legacy root string.
List<String> parseMealActionTips(Map<String, dynamic> json) {
  final tipsField = json['tips'];
  if (tipsField is Map) {
    final map = tipsField is Map<String, dynamic>
        ? tipsField
        : Map<String, dynamic>.from(tipsField);
    final list = map['tips'];
    if (list is List) {
      return list
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
  }
  if (tipsField is String && tipsField.trim().isNotEmpty) {
    return [tipsField.trim()];
  }
  return const [];
}

/// Parses `insight.keyInsights` with legacy fallback from does-well / improved lists.
List<FoodScoreInsightItem> parseKeyInsights(Map<String, dynamic> json) {
  final insight = json['insight'];
  if (insight is Map) {
    final map = insight is Map<String, dynamic>
        ? insight
        : Map<String, dynamic>.from(insight);
    final parsed = parseFoodScoreInsightList(map['keyInsights']);
    if (parsed.isNotEmpty) {
      return parsed;
    }
  }

  final legacy = <FoodScoreInsightItem>[
    ...parseFoodScoreInsightList(json['whatThisMealDoesWell']),
    ...parseFoodScoreInsightList(json['whatCouldBeImproved']),
  ];
  return legacy;
}
