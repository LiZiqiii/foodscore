/// Backend auth response user payload.
class AuthUser {
  const AuthUser({
    required this.userId,
    required this.username,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final userId = json['userId'];
    final username = json['username'];

    if (userId is! num || username is! String) {
      throw FormatException('Invalid auth user response.');
    }

    return AuthUser(
      userId: userId.toInt(),
      username: username.trim(),
    );
  }

  final int userId;
  final String username;

  /// Used by meal-record APIs (`user_id` is TEXT in SQLite).
  String get apiUserId => userId.toString();
}
