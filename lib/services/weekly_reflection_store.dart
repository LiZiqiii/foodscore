import '../models/weekly_reflection_meal.dart';

/// 内存中保存 weekly reflection 餐食（占位实现，后续可换本地持久化）。
class WeeklyReflectionStore {
  WeeklyReflectionStore._();

  static final WeeklyReflectionStore instance = WeeklyReflectionStore._();

  final List<WeeklyReflectionMeal> _meals = [];

  List<WeeklyReflectionMeal> get meals =>
      List.unmodifiable(_meals.reversed);

  bool get isEmpty => _meals.isEmpty;

  int get count => _meals.length;

  void addMeal({
    required String summary,
    bool isPhoto = false,
  }) {
    final trimmed = summary.trim();
    _meals.add(
      WeeklyReflectionMeal(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        summary: trimmed.isEmpty ? (isPhoto ? 'Meal photo' : 'Saved meal') : trimmed,
        savedAt: DateTime.now(),
        isPhoto: isPhoto,
      ),
    );
  }
}
