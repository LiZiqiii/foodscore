import '../models/weekly_reflection_meal.dart';
import '../models/weekly_reflection_summary.dart';

/// 从最近餐食记录生成的 Weekly Summary（规则聚合，API 失败时的 fallback）。
abstract final class WeeklyReflectionSummaryBuilder {
  static WeeklyReflectionSummary build(List<WeeklyReflectionMeal> meals) {
    if (meals.isEmpty) {
      return WeeklyReflectionSummary.empty;
    }

    final goodPatterns = <String>[];
    final smallFocus = <String>[];

    final feedbackCount = meals
        .where(
          (meal) => meal.status == WeeklyReflectionMealStatus.feedbackViewed,
        )
        .length;
    if (feedbackCount > 0) {
      goodPatterns.add(
        feedbackCount == 1
            ? 'You reviewed instant feedback on one meal.'
            : 'You reviewed instant feedback on $feedbackCount meals.',
      );
    }

    final reflectionOnlyCount = meals.length - feedbackCount;
    if (reflectionOnlyCount > 0) {
      goodPatterns.add(
        reflectionOnlyCount == 1
            ? 'You saved one meal for reflection without instant feedback.'
            : 'You saved $reflectionOnlyCount meals for reflection.',
      );
    }

    final tagCounts = <String, int>{};
    for (final meal in meals) {
      for (final tag in meal.tags) {
        if (tag == 'Saved for reflection') {
          continue;
        }
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final repeatedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in repeatedTags.where((e) => e.value >= 2).take(2)) {
      goodPatterns.add(
        '${entry.key} appeared in several meals this week.',
      );
    }

    if (goodPatterns.isEmpty) {
      goodPatterns.add(
        meals.length == 1
            ? 'You logged one meal in the last 7 days.'
            : 'You logged ${meals.length} meals in the last 7 days.',
      );
    }
    if (goodPatterns.length == 1) {
      goodPatterns.add(
        'Noticing small wins each week can make gentle changes feel easier.',
      );
    }

    for (final entry in repeatedTags.where((e) => e.value == 1).take(2)) {
      smallFocus.add(
        'When it feels right next week, you could explore ${entry.key.toLowerCase()}.',
      );
    }

    if (smallFocus.isEmpty) {
      smallFocus.add('Keep saving meals you want to reflect on next week.');
    }
    if (smallFocus.length == 1) {
      smallFocus.add(
        'When it feels right, you could add one more colourful vegetable to a meal this week.',
      );
    }

    return WeeklyReflectionSummary(
      goodPatterns: goodPatterns.take(2).toList(growable: false),
      smallFocus: smallFocus.take(2).toList(growable: false),
    );
  }
}
