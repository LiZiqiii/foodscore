import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import '../data/food_score_mock_data.dart';

/// 应用级配置：Mock 与本地 FastAPI 后端切换。
class AppConfig {
  AppConfig._();

  /// `true` — 使用 [MockFoodScoreService]，便于前端联调。
  /// `false` — 使用 [LocalApiFoodScoreService] 调用本地 FastAPI，再由后端请求 GPT。
  static const bool useMockResult = false;

  /// 本地 FastAPI 代理地址（仅当 [useMockResult] 为 `false` 时使用）。
  ///
  /// - Windows / iOS 模拟器 / 本机：127.0.0.1
  /// - Android 模拟器：10.0.2.2（指向宿主机）
  static String get localApiBaseUrl =>
      'https://adorable-courage-production-e7ce.up.railway.app';

  /// Weekly Reflection 滚动窗口天数（非自然周 Mon–Sun）。
  ///
  /// 仅包含 `saved_at / created_at >= 当前时刻 - weeklyReflectionDays` 的记录。
  static const int weeklyReflectionDays = 7;

  /// Mock 结果场景（仅当 [useMockResult] 为 `true` 时生效）。
  ///
  /// 切换 [MockResultScenario.high] / [MockResultScenario.medium] /
  /// [MockResultScenario.low] 后热重启，即可在 ResultPage 测试不同内容长度。
  static const MockResultScenario mockResultScenario = MockResultScenario.medium;
}
