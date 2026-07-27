/// UI-only preview model for Weekly Reflection meal cards (mock / prototype).
class WeeklyReflectionMealPreview {
  const WeeklyReflectionMealPreview({
    required this.mealName,
    required this.dayAndTime,
    required this.tags,
    required this.status,
  });

  final String mealName;
  final String dayAndTime;
  final List<String> tags;
  final String status;
}

/// Static mock data for Weekly Reflection page presentation.
class WeeklyReflectionMockData {
  WeeklyReflectionMockData._();

  /// When `true`, the page shows sample meals and summary instead of live store data.
  static const bool enabled = false;

  static const List<WeeklyReflectionMealPreview> recentMeals = [
    WeeklyReflectionMealPreview(
      mealName: 'Grilled chicken quinoa bowl',
      dayAndTime: 'Monday · Lunch',
      tags: ['Balanced', 'Protein included', 'Could add variety'],
      status: 'Feedback viewed',
    ),
    WeeklyReflectionMealPreview(
      mealName: 'Tomato pasta',
      dayAndTime: 'Wednesday · Dinner',
      tags: ['Whole food base', 'Sauce details unclear', 'Saved for reflection'],
      status: 'Saved for reflection only',
    ),
    WeeklyReflectionMealPreview(
      mealName: 'Egg and avocado toast',
      dayAndTime: 'Friday · Breakfast',
      tags: ['Protein included', 'Healthy fats included', 'Could add vegetables'],
      status: 'Feedback viewed',
    ),
  ];

  static const List<String> goodPatterns = [
    'Protein appeared in most recorded meals this week.',
    'Several meals included vegetables or whole-food bases.',
  ];

  static const List<String> smallFocus = [
    'Try adding one more colourful vegetable to a few meals.',
    'Choose lighter sauces when possible.',
  ];
}
