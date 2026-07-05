import '../config/app_config.dart';
import '../data/food_score_mock_data.dart';
import '../models/food_score_result.dart';
import 'food_score_service.dart';

/// Mock 餐食分析服务：返回固定示例数据，不调用真实 API。
///
/// TODO: Replace mock flow with FastAPI backend integration after front-end pages are finalised.
class MockFoodScoreService implements FoodScoreService {
  MockFoodScoreService({
    this.simulatedDelay = const Duration(seconds: 3),
    MockResultScenario? scenario,
  }) : _scenario = scenario ?? AppConfig.mockResultScenario;

  /// 模拟网络/分析耗时，与 Loading 页动画节奏一致。
  final Duration simulatedDelay;
  final MockResultScenario _scenario;

  /// 当前配置场景对应的 mock 结果。
  FoodScoreResult get activeResult =>
      FoodScoreMockData.resolve(_scenario);

  @override
  Future<FoodScoreResult> analyseMealFromText(String mealText) async {
    await Future<void>.delayed(simulatedDelay);
    return _resultForInput(mealText: mealText);
  }

  @override
  Future<FoodScoreResult> analyseMealFromImage({
    required String imagePath,
    String? description,
  }) async {
    await Future<void>.delayed(simulatedDelay);
    return _resultForInput(
      mealText: description,
      imagePath: imagePath,
    );
  }

  FoodScoreResult _resultForInput({String? mealText, String? imagePath}) {
    final base = activeResult;
    final trimmed = mealText?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      final snippet = trimmed.length > 48
          ? '${trimmed.substring(0, 48)}…'
          : trimmed;
      return FoodScoreResult(
        overallScore: base.overallScore,
        overallLabel: base.overallLabel,
        mealName: snippet,
        summary: base.summary,
        dimensions: base.dimensions,
        strengths: base.strengths,
        concerns: base.concerns,
        tips: base.tips,
        tipsHeadline: base.tipsHeadline,
      );
    }
    if (imagePath != null && imagePath.isNotEmpty) {
      return FoodScoreResult(
        overallScore: base.overallScore,
        overallLabel: base.overallLabel,
        mealName: 'Uploaded meal photo',
        summary: base.summary,
        dimensions: base.dimensions,
        strengths: base.strengths,
        concerns: base.concerns,
        tips: base.tips,
        tipsHeadline: base.tipsHeadline,
      );
    }
    return base;
  }
}
