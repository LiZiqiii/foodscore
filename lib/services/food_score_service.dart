import '../models/food_score_result.dart';

/// food score service exception
class FoodScoreServiceException implements Exception {
  FoodScoreServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// food score service abstract interface (Mock / local FastAPI can be switched)
abstract class FoodScoreService {
  /// analyse meal from text description
  ///
  /// [userId] when set, lets the backend load coaching preferences for personalised text.
  Future<FoodScoreResult> analyseMealFromText(
    String mealText, {
    String? userId,
  });

  /// analyse meal from image

  Future<FoodScoreResult> analyseMealFromImage({
    required String imagePath,
    List<int>? imageBytes,
    String? imageFileName,
    String? description,
    String? userId,
  });
}
