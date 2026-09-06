import '../models/weekly_reflection_meal.dart';
import '../models/weekly_reflection_summary.dart';
import 'weekly_reflection_summary_service.dart';

class MockWeeklyReflectionSummaryService
    implements WeeklyReflectionSummaryService {
  MockWeeklyReflectionSummaryService({
    this.simulatedDelay = const Duration(milliseconds: 1500),
  });

  final Duration simulatedDelay;

  @override
  Future<WeeklyReflectionSummary> buildSummary(
    List<WeeklyReflectionMeal> meals, {
    String? userId,
  }) async {
    if (meals.isEmpty) {
      return WeeklyReflectionSummary.empty;
    }

    await Future<void>.delayed(simulatedDelay);

    final hasFeedback = meals.any(
      (meal) => meal.status == WeeklyReflectionMealStatus.feedbackViewed,
    );

    final goodPatterns = <String>[
      if (hasFeedback)
        'Several meals included clear protein sources or whole-food bases.'
      else
        'Your logged meals show thoughtful choices you can build on this week.',
      meals.length >= 2
          ? 'You logged ${meals.length} meals this week — a helpful pattern to notice.'
          : 'Logging one meal is a solid start for weekly reflection.',
    ];

    return WeeklyReflectionSummary(
      goodPatterns: goodPatterns,
      smallFocus: const [
        'This week, try adding one more colourful vegetable when you log your next meal.',
        'Across the week ahead, a lighter sauce or dressing can be an easy small tweak.',
      ],
    );
  }
}
