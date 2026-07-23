import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/weekly_reflection_meal.dart';
import '../models/weekly_reflection_summary.dart';
import 'weekly_reflection_format.dart';
import 'weekly_reflection_summary_service.dart';

/// 通过本地 FastAPI 调用 GPT 生成 Weekly Summary。
class LocalApiWeeklyReflectionSummaryService
    implements WeeklyReflectionSummaryService {
  LocalApiWeeklyReflectionSummaryService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConfig.localApiBaseUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 60);

  @override
  Future<WeeklyReflectionSummary> buildSummary(
    List<WeeklyReflectionMeal> meals,
  ) async {
    if (meals.isEmpty) {
      return WeeklyReflectionSummary.empty;
    }

    final uri = Uri.parse('$baseUrl/weekly-summary');
    final body = jsonEncode({
      'meals': meals
          .map(
            (meal) => {
              'mealName': meal.mealName,
              'summary': meal.summary,
              'tags': meal.tags,
              'status': meal.status,
              'dayLabel': WeeklyReflectionFormat.dayAndTime(meal.savedAt),
            },
          )
          .toList(growable: false),
    });

    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw WeeklyReflectionSummaryException(
          _errorMessageFromBody(response),
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw WeeklyReflectionSummaryException(
          'Invalid weekly summary response.',
        );
      }

      final summary = WeeklyReflectionSummary.fromJson(decoded);
      if (summary.goodPatterns.isEmpty || summary.smallFocus.isEmpty) {
        throw WeeklyReflectionSummaryException(
          'Weekly summary response was incomplete.',
        );
      }

      return summary;
    } on WeeklyReflectionSummaryException {
      rethrow;
    } on FormatException catch (error) {
      throw WeeklyReflectionSummaryException(
        'Could not parse weekly summary: ${error.message}',
      );
    } catch (error) {
      throw WeeklyReflectionSummaryException(
        'Could not reach analysis server at $baseUrl. '
        'Is the FastAPI backend running? ($error)',
      );
    }
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
      // Fall through.
    }
    return 'Weekly summary server error (${response.statusCode}).';
  }
}
