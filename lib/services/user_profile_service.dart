import '../models/user_profile.dart';

abstract class UserProfileService {
  /// Returns null when the backend has no saved profile yet (404).
  Future<UserProfile?> loadProfile(String userId);

  Future<UserProfile> saveProfile(UserProfile profile);
}

class UserProfileServiceException implements Exception {
  UserProfileServiceException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
