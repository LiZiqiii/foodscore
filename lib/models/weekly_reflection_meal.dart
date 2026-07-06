/// 用户选择「Save for weekly reflection」时保存的餐食记录。
class WeeklyReflectionMeal {
  const WeeklyReflectionMeal({
    required this.id,
    required this.summary,
    required this.savedAt,
    this.isPhoto = false,
  });

  final String id;
  final String summary;
  final DateTime savedAt;
  final bool isPhoto;
}
