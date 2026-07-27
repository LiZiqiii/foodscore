/// 写入 Weekly Reflection 的餐食记录（Instant Feedback 或 Save for reflection）。
class WeeklyReflectionMeal {
  const WeeklyReflectionMeal({
    required this.id,
    required this.mealName,
    required this.summary,
    required this.savedAt,
    required this.tags,
    required this.status,
    this.mealText = '',
    this.isPhoto = false,
  });

  final String id;
  final String mealName;
  /// GPT / analysis one-line summary (shown on Records cards).
  final String summary;
  final DateTime savedAt;
  final List<String> tags;
  final String status;
  /// Original text description or photo note from upload/describe flow.
  final String mealText;
  final bool isPhoto;
}

/// 记录来源状态标签（UI 展示用）。
abstract final class WeeklyReflectionMealStatus {
  static const String feedbackViewed = 'Feedback viewed';
  static const String reflectionOnly = 'Saved for reflection only';
}
