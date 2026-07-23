import '../data/food_score_mock_data.dart';

/// 应用级配置：Mock 与本地 FastAPI 后端切换。
class AppConfig {
  AppConfig._();

  /// `true` — 使用 [MockFoodScoreService]，便于前端联调。
  /// `false` — 使用 [LocalApiFoodScoreService] 调用本地 FastAPI，再由后端请求 GPT。
  static const bool useMockResult = false;

  /// 本地 FastAPI 代理地址（仅当 [useMockResult] 为 `false` 时使用）。
  static const String localApiBaseUrl = 'http://127.0.0.1:8080';

  /// Mock 结果场景（仅当 [useMockResult] 为 `true` 时生效）。
  ///
  /// 切换 [MockResultScenario.high] / [MockResultScenario.medium] /
  /// [MockResultScenario.low] 后热重启，即可在 ResultPage 测试不同内容长度。
  static const MockResultScenario mockResultScenario = MockResultScenario.medium;
}