import '../models/weekly_reflection_meal.dart';
import '../models/weekly_reflection_summary.dart';
import 'weekly_reflection_summary_service.dart';

/// Mock Weekly Summary（联调 UI，不请求 GPT）。
class MockWeeklyReflectionSummaryService
    implements WeeklyReflectionSummaryService {
  MockWeeklyReflectionSummaryService({
    this.simulatedDelay = const Duration(milliseconds: 1500),
  });

  final Duration simulatedDelay;

  @override
  Future<WeeklyReflectionSummary> buildSummary(
    List<WeeklyReflectionMeal> meals,
  ) async {
    if (meals.isEmpty) {
      return WeeklyReflectionSummary.empty;
    }

    await Future<void>.delayed(simulatedDelay);

    final hasFeedback = meals.any(
      (meal) => meal.status == WeeklyReflectionMealStatus.feedbackViewed,
    );

    return WeeklyReflectionSummary(
      goodPatterns: [
        if (hasFeedback)
          'Several meals included clear protein sources or whole-food bases.',
        if (meals.length >= 2)
          'You logged ${meals.length} meals this week — a helpful reflection habit.',
        'Whole or minimally processed foods appeared in more than one entry.',
      ].where((line) => line.isNotEmpty).take(3).toList(growable: false),
      smallFocus: const [
        'Try adding one more colourful vegetable to a few meals.',
        'Choose lighter sauces when possible.',
      ],
    );
  }
}
