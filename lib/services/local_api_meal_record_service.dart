import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/food_score_result.dart';
import '../models/weekly_reflection_meal.dart';
import 'meal_record_service.dart';

/// Saves analysed meals via local FastAPI `POST /meal-records`.
class LocalApiMealRecordService implements MealRecordService {
  LocalApiMealRecordService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConfig.localApiBaseUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 30);

  @override
  Future<void> saveMealRecord({
    required String userId,
    required String mealText,
    required FoodScoreResult result,
  }) async {
    final trimmedMealText = mealText.trim();
    if (trimmedMealText.isEmpty) {
      throw MealRecordServiceException('Meal text is empty.');
    }

    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw MealRecordServiceException('User id is empty.');
    }

    final uri = Uri.parse('$baseUrl/meal-records');
    final body = jsonEncode({
      'userId': trimmedUserId,
      'mealText': trimmedMealText,
      'result': result.toJson(),
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
        throw MealRecordServiceException(_errorMessageFromBody(response));
      }
    } on MealRecordServiceException {
      rethrow;
    } on FormatException catch (error) {
      throw MealRecordServiceException(
        'Could not parse save-meal response: ${error.message}',
      );
    } catch (error) {
      throw MealRecordServiceException(
        'Could not reach meal record server at $baseUrl. '
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
      // Fall through to generic message.
    }
    return 'Meal record server error (${response.statusCode}).';
  }

  @override
  Future<List<WeeklyReflectionMeal>> fetchRecentMealRecords({
    required String userId,
    int? days,
    int limit = 30,
  }) async {
    final windowDays = days ?? AppConfig.weeklyReflectionDays;
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw MealRecordServiceException('User id is empty.');
    }

    final uri = Uri.parse('$baseUrl/meal-records/recent').replace(
      queryParameters: {
        'userId': trimmedUserId,
        'days': windowDays.toString(),
        'limit': limit.toString(),
      },
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw MealRecordServiceException(_errorMessageFromBody(response));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw MealRecordServiceException('Invalid recent meals response.');
      }

      final meals = decoded['meals'];
      if (meals is! List) {
        throw MealRecordServiceException('Invalid recent meals response.');
      }

      return meals
          .whereType<Map>()
          .map(
            (meal) => _mealFromBackendJson(
              Map<String, dynamic>.from(meal),
            ),
          )
          .toList(growable: false);
    } on MealRecordServiceException {
      rethrow;
    } on FormatException catch (error) {
      throw MealRecordServiceException(
        'Could not parse recent meals response: ${error.message}',
      );
    } catch (error) {
      throw MealRecordServiceException(
        'Could not reach meal record server at $baseUrl. '
        'Is the FastAPI backend running? ($error)',
      );
    }
  }

  WeeklyReflectionMeal _mealFromBackendJson(Map<String, dynamic> json) {
    final id = json['id'];
    final mealName = json['mealName'];
    final mealText = json['mealText'];
    final summary = json['summary'];
    final createdAt = json['createdAt'];
    final tags = json['tags'];

    if (id is! num ||
        mealName is! String ||
        summary is! String ||
        createdAt is! String) {
      throw MealRecordServiceException('Incomplete meal record in response.');
    }

    final parsedTags = <String>[];
    if (tags is List) {
      for (final tag in tags) {
        if (tag is String && tag.trim().isNotEmpty) {
          parsedTags.add(tag.trim());
        }
      }
    }

    final text = mealText is String ? mealText.trim() : '';
    final savedAt = DateTime.parse(createdAt).toLocal();

    return WeeklyReflectionMeal(
      id: id.toInt().toString(),
      mealName: mealName.trim(),
      summary: summary.trim(),
      savedAt: savedAt,
      tags: parsedTags.isEmpty
          ? const ['Saved for reflection']
          : parsedTags.take(3).toList(growable: false),
      status: WeeklyReflectionMealStatus.feedbackViewed,
      mealText: text,
      isPhoto: text.toLowerCase() == 'meal photo',
    );
  }
}
