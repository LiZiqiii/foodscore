import '../config/app_config.dart';
import 'food_score_service.dart';
import 'local_api_food_score_service.dart';
import 'mock_food_score_service.dart';

/// create corresponding analysis service instance based on [AppConfig.useMockResult]
FoodScoreService createFoodScoreService() {
  if (AppConfig.useMockResult) {
    return MockFoodScoreService();
  }
  return LocalApiFoodScoreService();
}
