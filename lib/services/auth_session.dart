import '../models/auth_user.dart';

/// In-memory logged-in user for the current app session.
class AuthSession {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  void setUser(AuthUser user) {
    _currentUser = user;
  }

  void clear() {
    _currentUser = null;
  }
}
