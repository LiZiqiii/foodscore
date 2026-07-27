import '../models/auth_user.dart';

abstract class AuthService {
  Future<AuthUser> register({
    required String username,
    required String password,
  });

  Future<AuthUser> login({
    required String username,
    required String password,
  });
}

class AuthServiceException implements Exception {
  AuthServiceException(this.message, {this.statusCode});

  static const String usernameExistsMessage = 'Username already exists.';

  final String message;
  final int? statusCode;

  bool get isUsernameConflict =>
      statusCode == 409 || message == usernameExistsMessage;

  @override
  String toString() => message;
}
