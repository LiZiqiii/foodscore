import 'dart:io';

import 'food_score_service.dart';

Future<List<int>> readImageBytesFromPath(String imagePath) async {
  final file = File(imagePath);
  if (!await file.exists()) {
    throw FoodScoreServiceException('Image file not found.');
  }
  return file.readAsBytes();
}
