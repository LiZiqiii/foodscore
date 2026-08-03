import '../models/user_profile.dart';
import '../models/weekly_reflection_meal.dart';
import '../models/weekly_reflection_summary.dart';

/// In-memory weekly summary cache keyed by records + coaching profile.
abstract final class WeeklyReflectionSummaryCache {
  static String? _userId;
  static String? _contextKey;
  static WeeklyReflectionSummary? _summary;

  static String recordsKey(List<WeeklyReflectionMeal> meals) {
    final ids = meals.map((meal) => meal.id).toList()..sort();
    return ids.join('|');
  }

  static String coachingKey(UserProfile? profile) {
    if (profile == null) {
      return 'none';
    }
    return [
      profile.ageRange ?? '',
      profile.heightCm ?? '',
      profile.weightKg ?? '',
      profile.dietaryPreference ?? '',
      profile.healthContext ?? '',
      profile.healthConditions.join('|'),
      profile.healthOtherNote ?? '',
      profile.updatedAt ?? '',
    ].join(';');
  }

  /// Bump when weekly summary copy rules change so cached text is regenerated.
  static const String _summaryFormatVersion = 'coaching-personalisation-v2';

  static String contextKey({
    required String userId,
    required List<WeeklyReflectionMeal> meals,
    required UserProfile? profile,
  }) {
    return '$userId|format:$_summaryFormatVersion|records:${recordsKey(meals)}|coaching:${coachingKey(profile)}';
  }

  static WeeklyReflectionSummary? get({
    required String userId,
    required String contextKey,
  }) {
    if (_userId == userId && _contextKey == contextKey && _summary != null) {
      return _summary;
    }
    return null;
  }

  static void save({
    required String userId,
    required String contextKey,
    required WeeklyReflectionSummary summary,
  }) {
    _userId = userId;
    _contextKey = contextKey;
    _summary = summary;
  }

  static void clear() {
    _userId = null;
    _contextKey = null;
    _summary = null;
  }
}
