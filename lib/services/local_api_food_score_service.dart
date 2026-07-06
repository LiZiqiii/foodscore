import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/food_score_result.dart';
import 'food_score_service.dart';

/// 通过本地 FastAPI 代理调用 GPT（Flutter 不持有 API key）。
class LocalApiFoodScoreService implements FoodScoreService {
  LocalApiFoodScoreService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConfig.localApiBaseUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 90);

  @override
  Future<FoodScoreResult> analyseMealFromText(String mealText) async {
    final trimmed = mealText.trim();
    if (trimmed.isEmpty) {
      throw FoodScoreServiceException('Meal description is empty.');
    }

    final uri = Uri.parse('$baseUrl/analyse-text');
    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'mealText': trimmed}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw FoodScoreServiceException(_errorMessageFromBody(response));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw FoodScoreServiceException('Invalid response from analysis server.');
      }

      return FoodScoreResult.fromJson(decoded);
    } on FoodScoreServiceException {
      rethrow;
    } on FormatException catch (error) {
      throw FoodScoreServiceException(
        'Could not parse analysis response: ${error.message}',
      );
    } catch (error) {
      throw FoodScoreServiceException(
        'Could not reach analysis server at $baseUrl. '
        'Is the FastAPI backend running? ($error)',
      );
    }
  }

  @override
  Future<FoodScoreResult> analyseMealFromImage({
    required String imagePath,
    String? description,
  }) async {
    throw FoodScoreServiceException(
      'Image analysis is not supported yet. Use text input or mock result.',
    );
  }

  String _errorMessageFromBody(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }
      }
    } catch (_) {
      // Fall through to generic message.
    }
    return 'Analysis server error (${response.statusCode}).';
  }
}
