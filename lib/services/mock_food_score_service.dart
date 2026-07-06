import '../config/app_config.dart';
import '../data/food_score_mock_data.dart';
import '../models/food_score_result.dart';
import 'food_score_service.dart';

class MockFoodScoreService implements FoodScoreService {
  MockFoodScoreService({
    this.simulatedDelay = const Duration(seconds: 3),
    MockResultScenario? scenario,
  }) : _scenario = scenario ?? AppConfig.mockResultScenario;

  final Duration simulatedDelay;
  final MockResultScenario _scenario;

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
        mealName: snippet,
        overallScore: base.overallScore,
        overallLabel: base.overallLabel,
        summary: base.summary,
        dimensions: base.dimensions,
        strengths: base.strengths,
        concerns: base.concerns,
        tips: base.tips,
        positiveNotes: base.positiveNotes,
        disclaimer: base.disclaimer,
      );
    }
    if (imagePath != null && imagePath.isNotEmpty) {
      return FoodScoreResult(
        mealName: 'Uploaded meal photo',
        overallScore: base.overallScore,
        overallLabel: base.overallLabel,
        summary: base.summary,
        dimensions: base.dimensions,
        strengths: base.strengths,
        concerns: base.concerns,
        tips: base.tips,
        positiveNotes: base.positiveNotes,
        disclaimer: base.disclaimer,
      );
    }
    return base;
  }
}
