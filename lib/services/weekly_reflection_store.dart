import '../models/food_score_result.dart';
import '../models/weekly_reflection_meal.dart';

/// 内存中保存 weekly reflection 餐食（占位实现，后续可换本地持久化）。
class WeeklyReflectionStore {
  WeeklyReflectionStore._();

  static final WeeklyReflectionStore instance = WeeklyReflectionStore._();

  static const Duration retentionPeriod = Duration(days: 7);

  final List<WeeklyReflectionMeal> _meals = [];

  /// 全部记录（新 → 旧）。
  List<WeeklyReflectionMeal> get meals =>
      List.unmodifiable(_meals.reversed);

  /// 最近 7 天内的记录（新 → 旧）。
  List<WeeklyReflectionMeal> get mealsWithinLast7Days {
    _purgeExpired();
    final cutoff = DateTime.now().subtract(retentionPeriod);
    return _meals
        .where((meal) => !meal.savedAt.isBefore(cutoff))
        .toList()
        .reversed
        .toList(growable: false);
  }

  bool get isEmpty => mealsWithinLast7Days.isEmpty;

  int get count => mealsWithinLast7Days.length;

  /// Instant Feedback 分析完成后写入（含 GPT mealName、summary、insight tags）。
  void addFromInstantFeedback(
    FoodScoreResult result, {
    bool isPhoto = false,
  }) {
    _purgeExpired();
    _meals.add(
      WeeklyReflectionMeal(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        mealName: _mealNameFromResult(result),
        summary: result.summary.trim(),
        savedAt: DateTime.now(),
        tags: _tagsFromResult(result),
        status: WeeklyReflectionMealStatus.feedbackViewed,
        isPhoto: isPhoto,
      ),
    );
  }

  /// Save for weekly reflection（无即时 Result，仅存用户描述）。
  void addMeal({
    required String summary,
    bool isPhoto = false,
  }) {
    _purgeExpired();
    final trimmed = summary.trim();
    _meals.add(
      WeeklyReflectionMeal(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        mealName: _mealNameFromSummary(trimmed, isPhoto: isPhoto),
        summary: trimmed.isEmpty
            ? (isPhoto ? 'Meal photo' : 'Saved meal')
            : trimmed,
        savedAt: DateTime.now(),
        tags: const ['Saved for reflection'],
        status: WeeklyReflectionMealStatus.reflectionOnly,
        isPhoto: isPhoto,
      ),
    );
  }

  void _purgeExpired() {
    final cutoff = DateTime.now().subtract(retentionPeriod);
    _meals.removeWhere((meal) => meal.savedAt.isBefore(cutoff));
  }

  static String _mealNameFromResult(FoodScoreResult result) {
    final name = result.mealName.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return _mealNameFromSummary(result.summary);
  }

  static String _mealNameFromSummary(
    String summary, {
    bool isPhoto = false,
  }) {
    final trimmed = summary.trim();
    if (trimmed.isEmpty) {
      return isPhoto ? 'Meal photo' : 'Saved meal';
    }

    final firstLine = trimmed.split(RegExp(r'[\n\.]')).first.trim();
    if (firstLine.length <= 48) {
      return firstLine;
    }
    return '${firstLine.substring(0, 45).trim()}…';
  }

  /// 从 Instant Feedback insight 提取 2–3 个 soft tags（与 Result 页一致，不另造矛盾标签）。
  static List<String> _tagsFromResult(FoodScoreResult result) {
    final tags = <String>[];

    for (final item in result.whatThisMealDoesWell) {
      if (tags.length >= 2) {
        break;
      }
      final title = item.title.trim();
      if (title.isNotEmpty) {
        tags.add(title);
      }
    }

    for (final item in result.whatCouldBeImproved) {
      if (tags.length >= 3) {
        break;
      }
      final title = item.title.trim();
      if (title.isNotEmpty && !tags.contains(title)) {
        tags.add(title);
      }
    }

    if (tags.isEmpty) {
      tags.add('Saved for reflection');
    }

    return tags.take(3).toList(growable: false);
  }
}
