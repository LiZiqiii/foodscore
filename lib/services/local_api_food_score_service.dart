import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/app_config.dart';
import '../models/food_score_result.dart';
import 'food_score_service.dart';
import 'local_api_food_score_service_io.dart'
    if (dart.library.html) 'local_api_food_score_service_stub.dart'
    as io_reader;

/// 通过本地 FastAPI 代理调用 GPT（Flutter 不持有 API key）。
class LocalApiFoodScoreService implements FoodScoreService {
  LocalApiFoodScoreService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConfig.localApiBaseUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 120);

  @override
  Future<FoodScoreResult> analyseMealFromText(
    String mealText, {
    String? userId,
  }) async {
    final trimmed = mealText.trim();
    if (trimmed.isEmpty) {
      throw FoodScoreServiceException('Meal description is empty.');
    }

    final body = <String, dynamic>{'mealText': trimmed};
    final trimmedUserId = userId?.trim();
    if (trimmedUserId != null && trimmedUserId.isNotEmpty) {
      body['userId'] = trimmedUserId;
    }

    final uri = Uri.parse('$baseUrl/analyse-text');
    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw FoodScoreServiceException(_errorMessageFromBody(response));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw FoodScoreServiceException('Invalid response from analysis server.');
      }

      return FoodScoreResult.fromJson(decoded);
    } on FoodScoreServiceException {
      rethrow;
    } on FormatException catch (error) {
      throw FoodScoreServiceException(
        'Could not parse analysis response: ${error.message}',
      );
    } catch (error) {
      throw FoodScoreServiceException(
        'Could not reach analysis server at $baseUrl. '
        'Is the FastAPI backend running? ($error)',
      );
    }
  }

  @override
  Future<FoodScoreResult> analyseMealFromImage({
    required String imagePath,
    List<int>? imageBytes,
    String? imageFileName,
    String? description,
    String? userId,
  }) async {
    final bytes = imageBytes ?? await io_reader.readImageBytesFromPath(imagePath);
    if (bytes.isEmpty) {
      throw FoodScoreServiceException('Image file not found or empty.');
    }

    final uri = Uri.parse('$baseUrl/analyse-image');
    final request = http.MultipartRequest('POST', uri);

    final trimmedDesc = description?.trim();
    if (trimmedDesc != null && trimmedDesc.isNotEmpty) {
      request.fields['description'] = trimmedDesc;
    }
    final trimmedUserId = userId?.trim();
    if (trimmedUserId != null && trimmedUserId.isNotEmpty) {
      request.fields['userId'] = trimmedUserId;
    }

    final nameHint = (imageFileName != null && imageFileName.isNotEmpty)
        ? imageFileName
        : imagePath;
    final mediaType = _mediaTypeForImagePath(nameHint);
    final uploadName = _uploadFilename(nameHint);

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: uploadName,
        contentType: mediaType,
      ),
    );

    try {
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw FoodScoreServiceException(_errorMessageFromBody(response));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw FoodScoreServiceException('Invalid response from analysis server.');
      }

      return FoodScoreResult.fromJson(decoded);
    } on FoodScoreServiceException {
      rethrow;
    } on FormatException catch (error) {
      throw FoodScoreServiceException(
        'Could not parse analysis response: ${error.message}',
      );
    } catch (error) {
      throw FoodScoreServiceException(
        'Could not reach analysis server at $baseUrl. '
        'Is the FastAPI backend running? ($error)',
      );
    }
  }

  MediaType _mediaTypeForImagePath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lower.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    return MediaType('image', 'jpeg');
  }

  String _uploadFilename(String pathOrName) {
    final normalized = pathOrName.replaceAll('\\', '/');
    final segment = normalized.split('/').last;
    if (segment.isNotEmpty && segment.contains('.')) {
      return segment;
    }
    return 'meal.jpg';
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
      // Fall through to generic message.
    }
    return 'Analysis server error (${response.statusCode}).';
  }
}
