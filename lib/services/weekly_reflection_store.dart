import '../config/app_config.dart';
import '../models/food_score_result.dart';
import '../models/weekly_reflection_meal.dart';

class WeeklyReflectionStore {
  WeeklyReflectionStore._();

  static final WeeklyReflectionStore instance = WeeklyReflectionStore._();

  static Duration get _retentionPeriod =>
      Duration(days: AppConfig.weeklyReflectionDays);

  final List<WeeklyReflectionMeal> _meals = [];
  final Map<String, FoodScoreResult> _resultsByMealId = {};

  FoodScoreResult? cachedResultFor(String mealId) => _resultsByMealId[mealId];

  void cacheResult(String mealId, FoodScoreResult result) {
    _resultsByMealId[mealId] = result;
  }


  List<WeeklyReflectionMeal> get meals =>
      List.unmodifiable(_meals.reversed);

  List<WeeklyReflectionMeal> get mealsWithinLast7Days {
    _purgeExpired();
    final cutoff = _rollingWindowCutoff();
    return _meals
        .where((meal) => !meal.savedAt.isBefore(cutoff))
        .toList()
        .reversed
        .toList(growable: false);
  }
  bool get isEmpty => mealsWithinLast7Days.isEmpty;

  int get count => mealsWithinLast7Days.length;
  void replaceMealsFromBackend(List<WeeklyReflectionMeal> mealsNewestFirst) {
    _meals
      ..clear()
      ..addAll(mealsNewestFirst.reversed);
    _resultsByMealId.clear();
  }

  void clear() {
    _meals.clear();
    _resultsByMealId.clear();
  }

  void addFromInstantFeedback(
    FoodScoreResult result, {
    bool isPhoto = false,
    required String mealText,
  }) {
    _addFromAnalysisResult(
      result,
      isPhoto: isPhoto,
      mealText: mealText,
      status: WeeklyReflectionMealStatus.feedbackViewed,
    );
  }
  void addFromReflectionSave(
    FoodScoreResult result, {
    bool isPhoto = false,
    required String mealText,
  }) {
    _addFromAnalysisResult(
      result,
      isPhoto: isPhoto,
      mealText: mealText,
      status: WeeklyReflectionMealStatus.reflectionOnly,
    );
  }

  void _addFromAnalysisResult(
    FoodScoreResult result, {
    required bool isPhoto,
    required String mealText,
    required String status,
  }) {
    _purgeExpired();
    final loggedText = _normalizeMealText(mealText, isPhoto: isPhoto);
    final mealId = DateTime.now().microsecondsSinceEpoch.toString();
    _resultsByMealId[mealId] = result;
    _meals.add(
      WeeklyReflectionMeal(
        id: mealId,
        mealName: _mealNameFromResult(result),
        summary: result.summary.trim(),
        savedAt: DateTime.now(),
        tags: _tagsFromResult(result),
        status: status,
        mealText: loggedText,
        isPhoto: isPhoto,
      ),
    );
  }

  void addMeal({
    required String summary,
    bool isPhoto = false,
  }) {
    _purgeExpired();
    final trimmed = summary.trim();
    final loggedText = _normalizeMealText(trimmed, isPhoto: isPhoto);
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
        mealText: loggedText,
        isPhoto: isPhoto,
      ),
    );
  }

  static String _normalizeMealText(String raw, {required bool isPhoto}) {
    final trimmed = raw.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return isPhoto ? 'Meal photo' : '';
  }

  void _purgeExpired() {
    final cutoff = _rollingWindowCutoff();
    _meals.removeWhere((meal) => meal.savedAt.isBefore(cutoff));
  }

  static DateTime _rollingWindowCutoff() {
    return DateTime.now().subtract(_retentionPeriod);
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

  static List<String> _tagsFromResult(FoodScoreResult result) {
    final tags = <String>[];

    for (final item in result.keyInsights) {
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
