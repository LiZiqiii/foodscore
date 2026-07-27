import 'user_profile_service.dart';
import 'local_api_user_profile_service.dart';

UserProfileService createUserProfileService() {
  return LocalApiUserProfileService();
}
