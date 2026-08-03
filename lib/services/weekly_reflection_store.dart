import '../config/app_config.dart';
import '../models/food_score_result.dart';
import '../models/weekly_reflection_meal.dart';

/// 内存中保存 weekly reflection 餐食；与后端 SQLite 同步时仍按滚动 7 天窗口过滤。
class WeeklyReflectionStore {
  WeeklyReflectionStore._();

  static final WeeklyReflectionStore instance = WeeklyReflectionStore._();

  static Duration get _retentionPeriod =>
      Duration(days: AppConfig.weeklyReflectionDays);

  final List<WeeklyReflectionMeal> _meals = [];
  final Map<String, FoodScoreResult> _resultsByMealId = {};

  /// Cached full feedback for a meal id when available in this session.
  FoodScoreResult? cachedResultFor(String mealId) => _resultsByMealId[mealId];

  void cacheResult(String mealId, FoodScoreResult result) {
    _resultsByMealId[mealId] = result;
  }

  /// 全部记录（新 → 旧），未按天数过滤。
  List<WeeklyReflectionMeal> get meals =>
      List.unmodifiable(_meals.reversed);

  /// 滚动窗口内记录（新 → 旧）：`savedAt >= now - weeklyReflectionDays`。
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

  /// 用后端最近记录替换内存列表（新 → 旧展示顺序由 [mealsWithinLast7Days] 保证）。
  /// 空列表也会清空，避免切换账号后仍显示上一用户的记录。
  void replaceMealsFromBackend(List<WeeklyReflectionMeal> mealsNewestFirst) {
    _meals
      ..clear()
      ..addAll(mealsNewestFirst.reversed);
    _resultsByMealId.clear();
  }

  /// 登出或切换账号时清空内存记录与缓存的完整 feedback。
  void clear() {
    _meals.clear();
    _resultsByMealId.clear();
  }
  /// Instant Feedback 分析完成后写入（含 GPT mealName、summary、insight tags）。
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

  /// Save for weekly reflection：同样走 GPT 分析，但不展示即时 Result 页。
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

  /// 无 GPT 时的兜底写入（当前 save 流程已改为先分析再存）。
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

  /// 从 Instant Feedback insight 提取 2–3 个 soft tags（与 Result 页一致，不另造矛盾标签）。
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
