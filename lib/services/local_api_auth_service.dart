import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/auth_user.dart';
import 'auth_service.dart';

/// Username/password auth via local FastAPI.
class LocalApiAuthService implements AuthService {
  LocalApiAuthService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConfig.localApiBaseUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 30);

  @override
  Future<AuthUser> register({
    required String username,
    required String password,
  }) {
    return _authenticate(
      path: '/auth/register',
      username: username,
      password: password,
    );
  }

  @override
  Future<AuthUser> login({
    required String username,
    required String password,
  }) {
    return _authenticate(
      path: '/auth/login',
      username: username,
      password: password,
    );
  }

  Future<AuthUser> _authenticate({
    required String path,
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty) {
      throw AuthServiceException('Username cannot be empty.');
    }
    if (password.isEmpty) {
      throw AuthServiceException('Password cannot be empty.');
    }

    final uri = Uri.parse('$baseUrl$path');
    final body = jsonEncode({
      'username': trimmedUsername,
      'password': password,
    });

    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        final statusCode = response.statusCode;
        final message = statusCode == 409
            ? AuthServiceException.usernameExistsMessage
            : _errorMessageFromBody(response);
        throw AuthServiceException(message, statusCode: statusCode);
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw AuthServiceException('Invalid auth response.');
      }

      return AuthUser.fromJson(decoded);
    } on AuthServiceException {
      rethrow;
    } on FormatException catch (error) {
      throw AuthServiceException(
        'Could not parse auth response: ${error.message}',
      );
    } catch (error) {
      throw AuthServiceException(
        'Could not reach auth server at $baseUrl. '
        'Is the FastAPI backend running? ($error)',
      );
    }
  }

  String _errorMessageFromBody(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }
      }
    } catch (_) {
      // Fall through.
    }
    return 'Auth server error (${response.statusCode}).';
  }
}
