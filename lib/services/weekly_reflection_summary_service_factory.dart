import '../config/app_config.dart';
import 'local_api_weekly_reflection_summary_service.dart';
import 'mock_weekly_reflection_summary_service.dart';
import 'weekly_reflection_summary_service.dart';

WeeklyReflectionSummaryService createWeeklyReflectionSummaryService() {
  if (AppConfig.useMockResult) {
    return MockWeeklyReflectionSummaryService();
  }
  return LocalApiWeeklyReflectionSummaryService();
}
