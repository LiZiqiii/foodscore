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

  static FoodScoreInsightItem _insight(String title, String description) {
    return FoodScoreInsightItem(title: title, description: description);
  }

  static final FoodScoreResult highScoreMockResult = FoodScoreResult(
    mealName: 'Grilled salmon with quinoa and roasted vegetables',
    overallScore: 85,
    overallLabel: 'Excellent',
    summary:
        'An excellent, well-balanced whole-food meal with strong variety and minimal processing concerns.',
    dimensions: [
      _dimension(
        0,
        score: 9,
        label: 'Excellent',
        feedback:
            'The meal includes salmon for protein, quinoa for carbohydrates, and roasted vegetables.',
      ),
      _dimension(
        1,
        score: 9,
        label: 'Excellent',
        feedback:
            'The meal contains protein, grains, and multiple vegetable colours from the roasted mix.',
      ),
      _dimension(
        2,
        score: 8,
        label: 'Very good',
        feedback:
            'Salmon, quinoa, and vegetables appear as mostly whole, minimally processed ingredients.',
      ),
      _dimension(
        3,
        score: 8,
        label: 'Very good',
        feedback:
            'No heavily processed sauces or ultra-processed items are evident in the description.',
      ),
    ],
    keyInsights: [
      _insight(
        'Balanced foundation',
        'Protein, complex carbohydrates, and vegetables are all represented, which aligns with strong balance and quality scores.',
      ),
      _insight(
        'Variety is a clear strength',
        'The strongest feature is the mix of food groups and colours across salmon, quinoa, and roasted vegetables.',
      ),
    ],
    mealTips: [
      'Consider adding a small handful of seeds or nuts for extra texture while keeping the salmon and vegetable base.',
    ],
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
        feedback:
            'The meal includes grilled chicken for protein, quinoa for carbohydrates, and salad vegetables.',
      ),
      _dimension(
        1,
        score: 8,
        label: 'Very good',
        feedback:
            'Mixed leaves, tomatoes, and quinoa bring several food groups and colours to the plate.',
      ),
      _dimension(
        2,
        score: 7,
        label: 'Good',
        feedback:
            'Chicken, quinoa, and fresh vegetables are mostly whole ingredients; the dressing type is not specified.',
      ),
      _dimension(
        3,
        score: 6,
        label: 'Fair',
        feedback:
            'A pre-made dressing may add sodium or sugar; other components appear lightly processed.',
      ),
    ],
    keyInsights: [
      _insight(
        'Solid structure overall',
        'Lean protein, whole grains, and vegetables together support the mid-to-high balance and variety scores.',
      ),
      _insight(
        'Dressing uncertainty limits the top score',
        'The overall score is held back mainly by unknown dressing ingredients rather than the chicken or vegetable base.',
      ),
    ],
    mealTips: [
      'Try olive oil and lemon instead of creamy dressing, and add avocado or walnuts for a clearer healthy fat source.',
    ],
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
            'The meal is dominated by refined flour pizza and garlic bread with processed meat and little visible produce.',
      ),
      _dimension(
        1,
        score: 2,
        label: 'Poor',
        feedback:
            'Food groups are narrow, with limited vegetable colour or plant variety described.',
      ),
      _dimension(
        2,
        score: 2,
        label: 'Poor',
        feedback:
            'Pepperoni, white-flour bases, and garlic bread are largely ultra-processed or refined components.',
      ),
      _dimension(
        3,
        score: 3,
        label: 'Poor',
        feedback:
            'Processed meat, refined carbs, and a fizzy drink likely add sodium, saturated fat, and added sugars.',
      ),
    ],
    keyInsights: [
      _insight(
        'Limited whole-food presence',
        'Across balance, variety, and quality dimensions, refined and ultra-processed items outweigh fresh produce.',
      ),
      _insight(
        'Processing drives the low total',
        'The low overall score is mainly tied to processed meat, refined flour, and the sugary drink rather than portion size alone.',
      ),
      _insight(
        'Protein without plant balance',
        'Some protein comes from pepperoni, but vegetables and whole grains are largely absent from what was described.',
      ),
    ],
    mealTips: [
      'Choose water instead of a fizzy drink and add a side salad with extra vegetable toppings on the pizza.',
    ],
    disclaimer: defaultDisclaimer,
  );
}
