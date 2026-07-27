import '../config/app_config.dart';
import 'local_api_meal_record_service.dart';
import 'meal_record_service.dart';

import 'auth_session.dart';

/// Legacy demo user id when no one is logged in.
const String demoUserId = 'demo-user';

/// Current user id for backend meal APIs.
String get currentUserId =>
    AuthSession.instance.currentUser?.apiUserId ?? demoUserId;
/// Creates a backend meal-record service when real API mode is enabled.
MealRecordService? createMealRecordService() {
  if (AppConfig.useMockResult) {
    return null;
  }
  return LocalApiMealRecordService();
}
