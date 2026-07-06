import '../models/food_score_result.dart';
import '../pages/result_page_controller.dart';

enum MockResultScenario {
  high,
  medium,
  low,
}

class FoodScoreMockData {
  FoodScoreMockData._();

  static const String defaultDisclaimer =
      'Meal-level feedback only. Not medical or nutrition advice.';

  static FoodScoreResult resolve(MockResultScenario scenario) {
    switch (scenario) {
      case MockResultScenario.high:
        return highScoreMockResult;
      case MockResultScenario.medium:
        return mediumScoreMockResult;
      case MockResultScenario.low:
        return lowScoreMockResult;
    }
  }

  static FoodScoreDimension _dimension(
    int index, {
    required int score,
    required String label,
    required String feedback,
  }) {
    final definition = ResultPageController.definitionAt(index);
    return FoodScoreDimension(
      name: definition.name,
      description: definition.description,
      score: score,
      label: label,
      feedback: feedback,
    );
  }

  static final FoodScoreResult highScoreMockResult = FoodScoreResult(
    mealName: 'Grilled salmon with quinoa and roasted vegetables',
    overallScore: 9,
    overallLabel: 'Excellent',
    summary: 'An excellent, well-balanced whole-food meal.',
    dimensions: [
      _dimension(
        0,
        score: 9,
        label: 'Excellent',
        feedback: 'Strong protein, complex carbs, and vegetables.',
      ),
      _dimension(
        1,
        score: 9,
        label: 'Excellent',
        feedback: 'Covers protein, grains, and multiple vegetable colours.',
      ),
      _dimension(
        2,
        score: 8,
        label: 'Very good',
        feedback: 'Mostly whole, minimally processed ingredients.',
      ),
      _dimension(
        3,
        score: 8,
        label: 'Very good',
        feedback: 'No major processing concerns identified.',
      ),
    ],
    strengths: const [
      InsightItem(
        title: 'Lean protein',
        description:
            'Salmon provides omega-3 fats and high-quality protein without excess saturated fat.',
        isPositive: true,
      ),
      InsightItem(
        title: 'Whole grains',
        description:
            'Quinoa adds fibre and complete plant protein alongside the vegetables.',
        isPositive: true,
      ),
    ],
    concerns: const [
      InsightItem(
        title: 'Portion awareness',
        description:
            'Salmon portions can be calorie-dense if regularly oversized.',
        isPositive: false,
      ),
    ],
    tips:
        'Keep this pattern — lean protein, whole grains, and colourful veg is a strong baseline. '
        'You could add a small handful of seeds for extra minerals without changing the meal much.',
    positiveNotes: const [
      'You are already close to an ideal meal pattern.',
    ],
    disclaimer: defaultDisclaimer,
  );

  static final FoodScoreResult mediumScoreMockResult = FoodScoreResult(
    mealName: 'Grilled chicken salad',
    overallScore: 7,
    overallLabel: 'Good',
    summary:
        'A balanced meal with lean protein, whole grains, and vegetables. '
        'Most ingredients appear minimally processed, though the dressing '
        'composition is uncertain.',
    dimensions: [
      _dimension(
        0,
        score: 7,
        label: 'Good',
        feedback: 'Good mix of protein, carbs, and vegetables.',
      ),
      _dimension(
        1,
        score: 8,
        label: 'Very good',
        feedback:
            'Includes different food groups, making the meal more diverse.',
      ),
      _dimension(
        2,
        score: 7,
        label: 'Good',
        feedback:
            'Contains mostly whole and minimally processed ingredients.',
      ),
      _dimension(
        3,
        score: 6,
        label: 'Fair',
        feedback:
            'Low in highly processed ingredients, but the sauce may contain added salt or sugar.',
      ),
    ],
    strengths: const [
      InsightItem(
        title: 'High-quality protein source',
        description:
            'Grilled chicken provides lean protein without excess saturated fat.',
        isPositive: true,
      ),
      InsightItem(
        title: 'Colourful vegetables',
        description:
            'Mixed leaves and vegetables add fibre and micronutrients to the meal.',
        isPositive: true,
      ),
      InsightItem(
        title: 'Whole grain carbohydrates',
        description: 'Quinoa is a complete protein and complex carbohydrate.',
        isPositive: true,
      ),
    ],
    concerns: const [
      InsightItem(
        title: 'Unknown dressing ingredients',
        description:
            'Pre-made dressings often contain added sugars, refined oils, and excess sodium. The exact composition is not visible.',
        isPositive: false,
      ),
      InsightItem(
        title: 'Limited healthy fat sources',
        description:
            'The meal could benefit from avocado, nuts, or olive oil to improve fat-soluble vitamin absorption.',
        isPositive: false,
      ),
    ],
    tips:
        'Add a healthy fat such as avocado or walnuts to support fat-soluble vitamin absorption. '
        'Swap creamy dressing for olive oil and lemon to reduce added sugar and refined oils. '
        'Include an extra vegetable portion to push variety and fibre closer to your daily target.',
    positiveNotes: const [
      'Small swaps can push your score from 7 to 8+ with minimal effort.',
    ],
    disclaimer: defaultDisclaimer,
  );

  static final FoodScoreResult lowScoreMockResult = FoodScoreResult(
    mealName: 'Large pepperoni pizza with garlic bread and fizzy drink',
    overallScore: 3,
    overallLabel: 'Poor',
    summary:
        'This meal is heavily skewed toward refined carbohydrates, saturated '
        'fat, and ultra-processed ingredients, with very little fibre or '
        'whole-food variety visible.',
    dimensions: [
      _dimension(
        0,
        score: 3,
        label: 'Poor',
        feedback:
            'Dominated by refined carbs and processed meat; lacks vegetables and whole grains.',
      ),
      _dimension(
        1,
        score: 2,
        label: 'Poor',
        feedback:
            'Very limited food-group diversity with minimal colour or plant variety.',
      ),
      _dimension(
        2,
        score: 2,
        label: 'Poor',
        feedback:
            'Multiple ultra-processed components including cured meat and refined flour.',
      ),
      _dimension(
        3,
        score: 3,
        label: 'Poor',
        feedback:
            'High processing level with likely excess sodium, saturated fat, and added sugars.',
      ),
    ],
    strengths: const [
      InsightItem(
        title: 'Provides energy',
        description:
            'The meal delivers quick calories, which may be acceptable occasionally in an otherwise balanced diet.',
        isPositive: true,
      ),
    ],
    concerns: const [
      InsightItem(
        title: 'Ultra-processed meat',
        description:
            'Processed pepperoni is typically high in sodium, saturated fat, and preservatives.',
        isPositive: false,
      ),
      InsightItem(
        title: 'Refined carbohydrate base',
        description:
            'White-flour pizza base lacks fibre and may spike blood glucose compared with whole-grain options.',
        isPositive: false,
      ),
      InsightItem(
        title: 'Sugary drink',
        description:
            'A fizzy drink adds empty calories and added sugar without supporting satiety.',
        isPositive: false,
      ),
      InsightItem(
        title: 'Minimal vegetables',
        description:
            'There is little visible plant food, reducing fibre and micronutrient intake for this meal.',
        isPositive: false,
      ),
    ],
    tips:
        'Swap half the pizza for a side salad with olive oil to add fibre and reduce refined-carb density. '
        'Choose water instead of a fizzy drink to cut added sugar. '
        'If ordering pizza again, pick a thin whole-grain base and add extra vegetable toppings. '
        'Limit processed meat to occasional use, and plan the next meal around vegetables, legumes, and whole grains.',
    positiveNotes: const [
      'Several small changes could move this meal from 3 toward 5–6 over time.',
    ],
    disclaimer: defaultDisclaimer,
  );
}
