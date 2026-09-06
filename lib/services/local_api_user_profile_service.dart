import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user_profile.dart';
import 'user_profile_service.dart';

/// Coaching profile via local FastAPI `/user-profile`.
class LocalApiUserProfileService implements UserProfileService {
  LocalApiUserProfileService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConfig.localApiBaseUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 30);
  @override
  Future<UserProfile?> loadProfile(String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw UserProfileServiceException('User id is empty.');
    }
    final uri = Uri.parse('$baseUrl/user-profile').replace(
      queryParameters: {'userId': trimmedUserId},
    );
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 404) {
        return null;
      }
      if (response.statusCode != 200) {
        throw UserProfileServiceException(
          _errorMessageFromBody(response),
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw UserProfileServiceException('Invalid profile response.');
      }
      return UserProfile.fromJson(decoded);
    } on UserProfileServiceException {
      rethrow;
    } on FormatException catch (error) {
      throw UserProfileServiceException(
        'Could not parse profile response: ${error.message}',
      );
    } catch (error) {
      throw UserProfileServiceException(
        'Could not reach profile server at $baseUrl. '
        'Is the FastAPI backend running? ($error)',
      );
    }
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    final trimmedUserId = profile.userId.trim();
    if (trimmedUserId.isEmpty) {
      throw UserProfileServiceException('User id is empty.');
    }

    final uri = Uri.parse('$baseUrl/user-profile');
    final body = jsonEncode(profile.toJson());

    try {
      final response = await _client
          .put(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw UserProfileServiceException(
          _errorMessageFromBody(response),
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw UserProfileServiceException('Invalid profile response.');
      }

      return UserProfile.fromJson(decoded);
    } on UserProfileServiceException {
      rethrow;
    } on FormatException catch (error) {
      throw UserProfileServiceException(
        'Could not parse profile response: ${error.message}',
      );
    } catch (error) {
      throw UserProfileServiceException(
        'Could not reach profile server at $baseUrl. '
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
    return 'Profile server error (${response.statusCode}).';
  }
}
