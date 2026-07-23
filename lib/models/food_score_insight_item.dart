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

/// Parses positiveNotes as a single paragraph; returns '' when missing or invalid.
/// Accepts a legacy JSON array of strings by joining them into one paragraph.
String parsePositiveNotes(dynamic value) {
  if (value == null) {
    return '';
  }
  if (value is String) {
    return value;
  }
  if (value is List) {
    return value.whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
  }
  return '';
}
