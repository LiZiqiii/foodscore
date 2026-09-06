

library;

// ignore_for_file: lines_longer_than_80_chars

/// Prompt text, JSON example and ResultPage field mapping.
abstract final class FoodScorePrompt {
  /// system prompt for GPT / backend
  static const String systemPrompt = '''
You are FoodScore, a meal-quality assessment assistant.

Your task: analyse a meal from the user's text description and/or meal photo, then return a structured food-quality assessment as a single JSON object.

Rules:
- Assess approximate meal-level food quality only — not medical advice, not precise nutrition calculation.
- Score everything on a 1–10 scale (integers only).
- Return exactly four dimensions in the fixed order listed below.
- For "Processing & Concerns", a HIGHER score means FEWER concerns (less ultra-processing, less added sugar/salt/sauces).
- Output ONLY valid JSON. No markdown fences, no commentary, no extra keys.
- All string fields must be in English unless the user's input is clearly in another language (then match the user's language for user-facing text).
''';

  /// GPT must return 4 dimensions in the fixed order; `name` and `description` must match the definitions exactly.
  static const List<FoodScoreDimensionPromptSpec> dimensionSpecs = [
    FoodScoreDimensionPromptSpec(
      name: 'Meal Balance',
      description: 'Protein, carbs, fats and vegetables.',
      scoringGuide:
          'Score how well the meal combines protein, carbohydrates, healthy fats, and vegetables in reasonable proportions. 10 = well-balanced plate; 1 = severely unbalanced (e.g. almost all refined carbs, no protein or veg).',
    ),
    FoodScoreDimensionPromptSpec(
      name: 'Food Variety',
      description: 'Different food groups, colours and ingredients.',
      scoringGuide:
          'Score diversity of food groups, colours, and ingredient types. 10 = many groups/colours; 1 = monotonous, single-category meal.',
    ),
    FoodScoreDimensionPromptSpec(
      name: 'Whole Food Quality',
      description: 'Fresh, whole and minimally processed foods.',
      scoringGuide:
          'Score how much of the meal appears fresh, whole, and minimally processed. 10 = mostly whole foods; 1 = mostly ultra-processed.',
    ),
    FoodScoreDimensionPromptSpec(
      name: 'Processing & Concerns',
      description: 'Added sugar, salt, sauces or ultra-processed items.',
      scoringGuide:
          'IMPORTANT: Higher score = FEWER concerns. Score 10 = minimal processing concerns; score 1 = heavy ultra-processing, sugary drinks, hidden sauces, excess salt/sugar. Do NOT invert this dimension.',
    ),
  ];

  /// user prompt template
  static const String textUserPromptPrefix = 'Analyse this meal description:\n\n';

  static const String imageUserPromptPrefix =
      'Analyse this meal from the attached photo';

  static const String imageUserPromptWithDescriptionSuffix =
      ' and the following description:\n\n';

  /// concatenate text input: `$textUserPromptPrefix$mealText`
  static String textUserPrompt(String mealText) =>
      '$textUserPromptPrefix$mealText';

  /// concatenate image input: `$imageUserPromptPrefix$description`
  static String imageUserPrompt({String? description}) {
    if (description == null || description.trim().isEmpty) {
      return '$imageUserPromptPrefix.';
    }
    return '$imageUserPromptPrefix$imageUserPromptWithDescriptionSuffix$description';
  }

  /// required JSON fields
  static const Map<String, String> responseFieldSpec = {
    'mealName':
        'Short human-readable name for the meal (e.g. "Grilled chicken salad").',
    'overallScore':
        'Integer 1–10. Overall food-quality score for the meal.',
    'overallLabel':
        'Short label matching overallScore (e.g. "Excellent", "Good", "Fair", "Poor").',
    'summary':
        'Brief paragraph summarising the meal quality assessment.',
    'dimensions':
        'Array of exactly 4 objects — fixed order: Meal Balance, Food Variety, Whole Food Quality, Processing & Concerns.',
    'insight':
        'Object with keyInsights: 2–3 synthesis cards (title + description) for Insight tab.',
    'insight.keyInsights':
        'Cross-dimension interpretation — no recommendations or action words.',
    'tips':
        'Object with tips: 1–2 actionable strings for Tips tab only.',
    'disclaimer':
        'Single string — e.g. meal-level feedback disclaimer on Tips tab.',
  };

  /// field spec for each dimension object
  static const Map<String, String> dimensionFieldSpec = {
    'name': 'Must exactly match one of the four fixed dimension names.',
    'description': 'Must exactly match the fixed description for that dimension.',
    'score': 'Integer 1–10 for this dimension.',
    'label': 'Short score label (e.g. "Good", "Fair").',
    'feedback':
        'One or two sentences explaining the score for this dimension.',
  };

  /// example JSON (for backend integration / GPT structured output reference)
  static const String exampleJson = '''
{
  "mealName": "Grilled chicken salad",
  "overallScore": 7,
  "overallLabel": "Good",
  "summary": "A balanced meal with lean protein, whole grains, and vegetables. Most ingredients appear minimally processed, though the dressing composition is uncertain.",
  "dimensions": [
    {
      "name": "Meal Balance",
      "description": "Protein, carbs, fats and vegetables.",
      "score": 7,
      "label": "Good",
      "feedback": "Good mix of protein, carbs, and vegetables."
    },
    {
      "name": "Food Variety",
      "description": "Different food groups, colours and ingredients.",
      "score": 8,
      "label": "Very good",
      "feedback": "Includes different food groups, making the meal more diverse."
    },
    {
      "name": "Whole Food Quality",
      "description": "Fresh, whole and minimally processed foods.",
      "score": 7,
      "label": "Good",
      "feedback": "Contains mostly whole and minimally processed ingredients."
    },
    {
      "name": "Processing & Concerns",
      "description": "Added sugar, salt, sauces or ultra-processed items.",
      "score": 6,
      "label": "Fair",
      "feedback": "Low in highly processed ingredients, but the sauce may contain added salt or sugar."
    }
  ],
  "insight": {
    "keyInsights": [
      {
        "title": "Solid structure overall",
        "description": "Lean protein, whole grains, and vegetables together support the balance and variety scores."
      },
      {
        "title": "Dressing uncertainty limits the top score",
        "description": "The overall score is held back mainly by unknown dressing ingredients rather than the chicken or vegetable base."
      }
    ]
  },
  "tips": {
    "tips": [
      "Try olive oil and lemon instead of creamy dressing, and add avocado or walnuts for a clearer healthy fat source."
    ]
  },
  "disclaimer": "Meal-level feedback only. Not medical or nutrition advice."
}
''';

  // ResultPage three pages mapping
 
  static const Map<String, String> scoreTabFieldMapping = {
    'overallScore': 'Hero 分数（OUT OF 100）',
    'overallLabel': '分数下方标签',
    'mealName': '餐食名称',
    'summary': '名称下方摘要段落',
    'dimensions[].feedback': '各维度 factual 评分依据（无建议用语）',
  };

  static const Map<String, String> insightTabFieldMapping = {
    'mealName': 'Insight hero 卡片',
    'overallScore': 'Insight hero 右侧分数',
    'insight.keyInsights[]': 'KEY INSIGHTS 白色卡片（title + description）',
  };
  static const Map<String, String> tipsTabFieldMapping = {
    'tips.tips[]': '1–2 条可执行建议（白色 lightbulb 卡片）',
    'disclaimer': '底部 Remember 免责声明',
  };

  static String buildSystemPromptWithSchema() {
    final buffer = StringBuffer(systemPrompt)
      ..writeln()
      ..writeln('Fixed dimensions (exact order, exact name and description):');

    for (var i = 0; i < dimensionSpecs.length; i++) {
      final spec = dimensionSpecs[i];
      buffer
        ..writeln('${i + 1}. ${spec.name}')
        ..writeln('   description: ${spec.description}')
        ..writeln('   scoring: ${spec.scoringGuide}')
        ..writeln();
    }

    buffer
      ..writeln('Required JSON root keys: ${responseFieldSpec.keys.join(', ')}')
      ..writeln('Each dimension object keys: ${dimensionFieldSpec.keys.join(', ')}')
      ..writeln()
      ..writeln('Example response shape:')
      ..writeln(exampleJson.trim());

    return buffer.toString();
  }
}

class FoodScoreDimensionPromptSpec {
  const FoodScoreDimensionPromptSpec({
    required this.name,
    required this.description,
    required this.scoringGuide,
  });
  final String name;
  final String description;
  final String scoringGuide;
}
