import '../models/weekly_reflection_meal.dart';
import '../models/weekly_reflection_summary.dart';

/// Weekly Summary generation exception
class WeeklyReflectionSummaryException implements Exception {
  WeeklyReflectionSummaryException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// build Weekly Summary from recent meal records
abstract class WeeklyReflectionSummaryService {
  Future<WeeklyReflectionSummary> buildSummary(
    List<WeeklyReflectionMeal> meals, {
    String? userId,
  });
}
