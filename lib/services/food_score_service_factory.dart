import '../config/app_config.dart';
import 'food_score_service.dart';
import 'local_api_food_score_service.dart';
import 'mock_food_score_service.dart';

/// 根据 [AppConfig.useMockResult] 创建对应的分析服务实例。
FoodScoreService createFoodScoreService() {
  if (AppConfig.useMockResult) {
    return MockFoodScoreService();
  }
  return LocalApiFoodScoreService();
}
