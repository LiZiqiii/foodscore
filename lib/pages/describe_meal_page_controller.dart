import 'package:flutter/material.dart';

/// 文字描述餐食页控制器。
class DescribeMealPageController {
  DescribeMealPageController._();

  static const String backLabel = '<  Back';
  static const String title = 'Describe your meal';
  static const String subtitle =
      'Tell FoodScore what you ate, and it will estimate the meal quality .Be as specific as you possible. ';
  static const String inputHint =
      'e.g.I had a large bowl of grilled chicken salad with quinoa, mixed leaves, cucumber,tomatoes, and a Caesar dressing. I also had a glass of orange juice.';
  static const String ctaLabel = 'Continue';
  static const String disclaimerLine1 = 'Approximate meal-level feedback.';
  static const String disclaimerLine2 =
      'Not medical advice or precise nutrient calculation.';

  static const List<String> tips = [
    'Drinks',
    'Sauces',
    'Cooking method',
    'Other details',
  ];

  // 颜色
  static const Color backgroundColor = Color(0xFFF6FAF0);
  static const Color backColor = Color(0xFF1A6731);
  static const Color titleColor = Color(0xFF4A4B48);
  static const Color subtitleColor = Color(0xFF878984);
  static const Color inputBg = Color(0xFFFAFCFA);
  static const Color inputBorderColor = Color(0x0D082310);
  static const Color inputHintColor = Color(0xFF959694);
  static const Color inputTextColor = Color(0xFF4A4B48);
  static const Color tipBg = Color(0xFFE1F4F0);
  static const Color tipTextColor = Color(0xFF3D6C47);
  static const Color ctaDisabledBg = Color(0xFFEBEBEB);
  static const Color ctaDisabledText = Color(0xFFD0DAD3);
  static const Color ctaEnabledBg = Color(0xFF1A6731);
  static const Color disclaimerColor = Color(0xFF8A8C88);

  // CTA — 与 home page 一致
  static const double ctaHeight = 48;
  static const double ctaRadius = 15;
  static const double ctaFontSize = 16;
  static const double ctaIconSize = 18;
  static const double ctaIconGap = 6;
  static const double horizontalPadding = 24;
  static const double topExtraPadding = 10;
  static const double backToTitleGap = 18;
  static const double titleToSubtitleGap = 12;
  static const double subtitleFontSize = 14;
  static const double subtitleToInputGap = 26;
  static const double inputHeight = 198;
  static const double inputPaddingH = 14;
  static const double inputPaddingV = 12;
  static const double inputFontSize = 14;
  static const double inputLineHeight = 25 / 14;
  static const double inputRadiusTL = 16;
  static const double inputRadiusTR = 19;
  static const double inputRadiusBL = 18;
  static const double inputRadiusBR = 25;
  static const double inputToTipsGap = 28;
  static const double tipRowGap = 13;
  static const double tipChipHeight = 25;
  static const double tipFontSize = 13;
  static const double tipIconSize = 11;
  static const double tipIconGap = 3;
  static const double tipChipPaddingH = 8;
  static const double ctaToDisclaimerGap = 36;
  static const double disclaimerBottomPadding = 20;
  static const double tipsToCtaGap = 40;
}
