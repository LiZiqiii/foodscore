import '../config/app_config.dart';
import '../models/food_score_result.dart';
import 'food_score_service.dart';

/// 通过本地 FastAPI 代理调用 GPT 的餐食分析服务。
///
/// GPT prompt 与 JSON schema 对齐说明见 `lib/prompts/food_score_prompt.dart`。
///
/// TODO: Replace mock flow with FastAPI backend integration after front-end pages are finalised.
class LocalApiFoodScoreService implements FoodScoreService {  LocalApiFoodScoreService({String? baseUrl})
      : baseUrl = baseUrl ?? AppConfig.localApiBaseUrl;

  final String baseUrl;

  @override
  Future<FoodScoreResult> analyseMealFromText(String mealText) async {
    // TODO: POST $baseUrl/analyse-text
    // Request body: {'meal_text': mealText}
    // Response: JSON matching FoodScoreResult fields — add fromJson when backend schema is final.
    // Example:
    // final uri = Uri.parse('$baseUrl/analyse-text');
    // final response = await http.post(uri, body: jsonEncode({'meal_text': mealText}), ...);
    // if (response.statusCode != 200) throw FoodScoreServiceException(...);
    // return FoodScoreResult.fromJson(jsonDecode(response.body));
    throw FoodScoreServiceException(
      'Local API text analysis is not implemented yet. '
      'Set AppConfig.useMockResult = true or complete this service.',
    );
  }

  @override
  Future<FoodScoreResult> analyseMealFromImage({
    required String imagePath,
    String? description,
  }) async {
    // TODO: POST $baseUrl/analyse-image (multipart: image file + optional description)
    // Response: JSON matching FoodScoreResult fields.
    throw FoodScoreServiceException(
      'Local API image analysis is not implemented yet. '
      'Set AppConfig.useMockResult = true or complete this service.',
    );
  }
}
