import '../models/food_score_result.dart';

/// 用于 ResultPage 动态内容测试的 mock 场景。
enum MockResultScenario {
  /// 高分 · 短 summary · 2 条 tips
  high,

  /// 中等分 · 中等 summary · 3 条 tips
  medium,

  /// 低分 · 长 summary · 4–5 条 tips
  low,
}

/// FoodScoreResult 测试用 mock 数据集。
///
/// 在 [AppConfig.mockResultScenario] 中切换场景，热重启后生效。
class FoodScoreMockData {
  FoodScoreMockData._();

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

  /// 高分 · 短 summary · 2 条 tips
  static const FoodScoreResult highScoreMockResult = FoodScoreResult(
    overallScore: 9,
    overallLabel: 'Excellent',
    mealName: 'Grilled salmon with quinoa and roasted vegetables',
    summary: 'An excellent, well-balanced whole-food meal.',
    dimensions: [
      ResultDimension(
        description: 'Strong protein, complex carbs, and vegetables.',
        score: 9,
        label: 'Excellent',
      ),
      ResultDimension(
        description: 'Covers protein, grains, and multiple vegetable colours.',
        score: 9,
        label: 'Excellent',
      ),
      ResultDimension(
        description: 'Mostly whole, minimally processed ingredients.',
        score: 8,
        label: 'Very good',
      ),
      ResultDimension(
        description: 'No major processing concerns identified.',
        score: 8,
        label: 'Very good',
      ),
    ],
    strengths: [
      InsightItem(
        title: 'Lean protein',
        description: 'Salmon provides omega-3 fats and high-quality protein.',
        isPositive: true,
      ),
      InsightItem(
        title: 'Whole grains',
        description: 'Quinoa adds fibre and complete plant protein.',
        isPositive: true,
      ),
    ],
    concerns: [
      InsightItem(
        title: 'Portion awareness',
        description:
            'Salmon portions can be calorie-dense if regularly oversized.',
        isPositive: false,
      ),
    ],
    tips: [
      ImprovementTip(
        text:
            'Keep this pattern — lean protein, whole grains, and colourful veg is a strong baseline.',
      ),
      ImprovementTip(
        text:
            'Add a small handful of seeds for extra minerals without changing the meal much.',
      ),
    ],
    tipsHeadline: 'You are already close to an ideal meal pattern.',
  );

  /// 中等分 · 中等 summary · 3 条 tips
  static const FoodScoreResult mediumScoreMockResult = FoodScoreResult(
    overallScore: 7,
    overallLabel: 'Good',
    mealName: 'Grilled chicken salad',
    summary:
        'A balanced meal with lean protein, whole grains, and vegetables. '
        'Most ingredients appear minimally processed, though the dressing '
        'composition is uncertain.',
    dimensions: [
      ResultDimension(
        description: 'Good mix of protein, carbs, and vegetables.',
        score: 7,
        label: 'Good',
      ),
      ResultDimension(
        description:
            'Includes different food groups, making the meal more diverse.',
        score: 8,
        label: 'Very good',
      ),
      ResultDimension(
        description:
            'Contains mostly whole and minimally processed ingredients.',
        score: 7,
        label: 'Good',
      ),
      ResultDimension(
        description:
            'Low in highly processed ingredients, but the sauce may contain added salt or sugar.',
        score: 6,
        label: 'Fair',
      ),
    ],
    strengths: [
      InsightItem(
        title: 'High-quality protein source',
        description:
            'Grilled chicken provides lean protein without excess saturated fat.',
        isPositive: true,
      ),
      InsightItem(
        title: 'Whole grain carbohydrates',
        description: 'Quinoa is a complete protein and complex carb.',
        isPositive: true,
      ),
      InsightItem(
        title: 'Colourful vegetables',
        description:
            'Mixed leaves and vegetables add fibre and micronutrients.',
        isPositive: true,
      ),
    ],
    concerns: [
      InsightItem(
        title: 'Unknown dressing ingredients',
        description:
            'Pre-made dressings often contain added sugars, refined oils, and excess sodium. The exact composition isn\'t visible.',
        isPositive: false,
      ),
      InsightItem(
        title: 'Limited healthy fat sources',
        description:
            'The meal could benefit from avocado, nuts, or olive oil to improve fat-soluble vitamin absorption.',
        isPositive: false,
      ),
    ],
    tips: [
      ImprovementTip(
        text:
            'Add a healthy fat. Slice in half an avocado or add a handful of walnuts to support fat-soluble vitamin absorption.',
      ),
      ImprovementTip(
        text:
            'Swap creamy dressing for olive oil and lemon to reduce added sugar and refined oils.',
      ),
      ImprovementTip(
        text:
            'Include an extra vegetable portion to push variety and fibre closer to your daily target.',
      ),
    ],
    tipsHeadline:
        'Small swaps can push your score from 7 to 8+ with minimal effort.',
  );

  /// 低分 · 长 summary · 5 条 tips
  static const FoodScoreResult lowScoreMockResult = FoodScoreResult(
    overallScore: 3,
    overallLabel: 'Poor',
    mealName: 'Large pepperoni pizza with garlic bread and fizzy drink',
    summary:
        'This meal is heavily skewed toward refined carbohydrates, saturated '
        'fat, and ultra-processed ingredients, with very little fibre or '
        'whole-food variety visible. The combination of processed meat, white '
        'flour base, sugary drink, and limited vegetables makes it difficult '
        'to support balanced nutrition in a single sitting. Repeated meals '
        'like this may contribute to excess sodium, added sugars, and low '
        'micronutrient density over time.',
    dimensions: [
      ResultDimension(
        description:
            'Dominated by refined carbs and processed meat; lacks vegetables and whole grains.',
        score: 3,
        label: 'Poor',
      ),
      ResultDimension(
        description:
            'Very limited food-group diversity — mostly one category with minimal colour or plant variety.',
        score: 2,
        label: 'Poor',
      ),
      ResultDimension(
        description:
            'Multiple ultra-processed components including cured meat, refined flour, and sweetened drink.',
        score: 2,
        label: 'Poor',
      ),
      ResultDimension(
        description:
            'High processing level with likely excess sodium, saturated fat, and added sugars throughout.',
        score: 3,
        label: 'Poor',
      ),
    ],
    strengths: [
      InsightItem(
        title: 'Provides energy',
        description:
            'The meal delivers quick calories, which may be acceptable occasionally in an otherwise balanced diet.',
        isPositive: true,
      ),
    ],
    concerns: [
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
            'A fizzy drink adds empty calories and added sugar without supporting satiety or micronutrient intake.',
        isPositive: false,
      ),
      InsightItem(
        title: 'Minimal vegetables',
        description:
            'There is little visible plant food, reducing fibre, potassium, and antioxidant intake for this meal.',
        isPositive: false,
      ),
    ],
    tips: [
      ImprovementTip(
        text:
            'Swap half the pizza for a side salad with olive oil to add fibre and reduce refined-carb density.',
      ),
      ImprovementTip(
        text:
            'Choose water or unsweetened sparkling water instead of a fizzy drink to cut added sugar.',
      ),
      ImprovementTip(
        text:
            'If ordering pizza, pick a thin whole-grain base and add extra vegetable toppings.',
      ),
      ImprovementTip(
        text:
            'Limit processed meat to occasional use and prefer lean unprocessed protein sources at other meals.',
      ),
      ImprovementTip(
        text:
            'Plan the next meal around vegetables, legumes, and whole grains to rebalance the day.',
      ),
    ],
    tipsHeadline:
        'Several small changes could move this meal from 3 toward 5–6 over time.',
  );
}
