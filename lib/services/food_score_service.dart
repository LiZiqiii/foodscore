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
  ///
  /// [userId] when set, lets the backend load coaching preferences for personalised text.
  Future<FoodScoreResult> analyseMealFromText(
    String mealText, {
    String? userId,
  });

  /// 根据餐食照片分析餐食质量。
  ///
  /// [description] 为可选补充说明，可提高分析准确度。
  /// [userId] when set, lets the backend load coaching preferences for personalised text.
  /// [imageBytes] — pass when running on web (from [XFile.readAsBytes]); optional on mobile.
  /// [imageFileName] — original file name for multipart upload (e.g. from [XFile.name]).
  Future<FoodScoreResult> analyseMealFromImage({
    required String imagePath,
    List<int>? imageBytes,
    String? imageFileName,
    String? description,
    String? userId,
  });
}
