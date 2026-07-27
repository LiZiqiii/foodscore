import '../models/weekly_reflection_meal.dart';
import '../models/weekly_reflection_summary.dart';

/// Weekly Summary 生成异常。
class WeeklyReflectionSummaryException implements Exception {
  WeeklyReflectionSummaryException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 根据最近餐食生成 Weekly Summary（Mock / 本地 FastAPI + GPT）。
abstract class WeeklyReflectionSummaryService {
  Future<WeeklyReflectionSummary> buildSummary(
    List<WeeklyReflectionMeal> meals, {
    String? userId,
  });
}
