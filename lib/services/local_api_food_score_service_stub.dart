import 'food_score_service.dart';

Future<List<int>> readImageBytesFromPath(String imagePath) async {
  throw FoodScoreServiceException(
    'On web, pass image bytes from the selected photo (XFile.readAsBytes).',
  );
}
