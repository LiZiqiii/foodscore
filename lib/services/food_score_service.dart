import '../models/food_score_result.dart';

/// 餐食分析服务异常。
class FoodScoreServiceException implements Exception {
  FoodScoreServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 餐食分析服务抽象接口（Mock / 本地 FastAPI 可切换）。
abstract class FoodScoreService {
  /// 根据文字描述分析餐食质量。
  Future<FoodScoreResult> analyseMealFromText(String mealText);

  /// 根据餐食照片分析餐食质量。
  ///
  /// [description] 为可选补充说明，可提高分析准确度。
  Future<FoodScoreResult> analyseMealFromImage({
    required String imagePath,
    String? description,
  });
}
