import '../models/food_score_insight_item.dart';
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

  static FoodScoreInsightItem _well(String title, String description) {
    return FoodScoreInsightItem(title: title, description: description);
  }

  static final FoodScoreResult highScoreMockResult = FoodScoreResult(
    mealName: 'Grilled salmon with quinoa and roasted vegetables',
    overallScore: 85,
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
    whatThisMealDoesWell: [
      _well(
        'Lean protein',
        'Salmon provides omega-3 fats and high-quality protein without excess saturated fat.',
      ),
      _well(
        'Whole grains',
        'Quinoa adds fibre and complete plant protein alongside the vegetables.',
      ),
    ],
    whatCouldBeImproved: [
      _well(
        'Portion awareness',
        'Salmon portions can be calorie-dense if regularly oversized.',
      ),
    ],
    tips:
        'Next time, you could add a small handful of seeds for extra texture, or include one more colourful vegetable to build on the variety you already have.',
    positiveNotes:
        'This meal includes lean protein from salmon, whole grains from quinoa, and a colourful vegetable mix. '
        'Most ingredients appear minimally processed, which supports a strong overall food quality score.',
    disclaimer: defaultDisclaimer,
  );

  static final FoodScoreResult mediumScoreMockResult = FoodScoreResult(
    mealName: 'Grilled chicken salad',
    overallScore: 70,
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
    whatThisMealDoesWell: [
      _well(
        'High-quality protein source',
        'Grilled chicken provides lean protein without excess saturated fat.',
      ),
      _well(
        'Colourful vegetables',
        'Mixed leaves and vegetables add fibre and micronutrients to the meal.',
      ),
      _well(
        'Whole grain carbohydrates',
        'Quinoa is a complete protein and complex carbohydrate.',
      ),
    ],
    whatCouldBeImproved: [
      _well(
        'Unknown dressing ingredients',
        'Pre-made dressings often contain added sugars, refined oils, and excess sodium. The exact composition is not visible.',
      ),
      _well(
        'Limited healthy fat sources',
        'The meal could benefit from avocado, nuts, or olive oil to improve fat-soluble vitamin absorption.',
      ),
    ],
    tips:
        'Next time, you could swap creamy dressing for olive oil and lemon, and add avocado or walnuts for a clearer healthy fat source.',
    positiveNotes:
        'This meal includes a clear protein source from grilled chicken, whole grains from quinoa, and colourful vegetables from mixed leaves and tomatoes. '
        'These choices support meal balance and variety.',
    disclaimer: defaultDisclaimer,
  );

  static final FoodScoreResult lowScoreMockResult = FoodScoreResult(
    mealName: 'Large pepperoni pizza with garlic bread and fizzy drink',
    overallScore: 25,
    overallLabel: 'Could be improved',
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
    whatThisMealDoesWell: [
      _well(
        'Provides energy',
        'The meal delivers quick calories, which may be acceptable occasionally in an otherwise balanced diet.',
      ),
    ],
    whatCouldBeImproved: [
      _well(
        'Ultra-processed meat',
        'Processed pepperoni is typically high in sodium, saturated fat, and preservatives.',
      ),
      _well(
        'Refined carbohydrate base',
        'White-flour pizza base lacks fibre and may spike blood glucose compared with whole-grain options.',
      ),
      _well(
        'Sugary drink',
        'A fizzy drink adds empty calories and added sugar without supporting satiety.',
      ),
      _well(
        'Minimal vegetables',
        'There is little visible plant food, reducing fibre and micronutrient intake for this meal.',
      ),
    ],
    tips:
        'Next time, you could choose water instead of a fizzy drink and add a side salad with extra vegetable toppings to improve variety.',
    positiveNotes:
        'This meal provides a familiar combination of pizza and garlic bread. '
        'There is some protein from the pepperoni, though plant foods and whole-food variety are limited in what was described.',
    disclaimer: defaultDisclaimer,
  );
}
