import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import '../data/food_score_mock_data.dart';
class AppConfig {
  AppConfig._();
  static const bool useMockResult = false;
  static String get localApiBaseUrl =>
      'https://adorable-courage-production-e7ce.up.railway.app';
  static const int weeklyReflectionDays = 7;
  static const MockResultScenario mockResultScenario = MockResultScenario.medium;
}
