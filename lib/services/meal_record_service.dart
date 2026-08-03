import '../models/food_score_result.dart';
import '../models/weekly_reflection_meal.dart';

/// Persists analysed meals to the backend SQLite store.
abstract class MealRecordService {
  Future<void> saveMealRecord({
    required String userId,
    required String mealText,
    required FoodScoreResult result,
  });

  Future<List<WeeklyReflectionMeal>> fetchRecentMealRecords({
    required String userId,
    int? days,
    int limit = 30,
  });

  Future<FoodScoreResult> fetchMealRecordResult({
    required String userId,
    required String mealId,
  });
}

class MealRecordServiceException implements Exception {
  MealRecordServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
