import 'package:flutter/material.dart';

/// 分享餐食方式选择页控制器。
class ShareMealPageController {
  ShareMealPageController._();

  static const String backLabel = '<  Back';
  static const String titleLine1 = 'How would you like to share';
  static const String titleLine2 = 'your meal?';
  static const String subtitle = 'Choose whichever feels easiest — both work great.';

  static const String photoCardTitle = 'Snap a photo';
  static const String photoCardSubtitle = 'Most accurate — we can see your meal';

  static const String textCardTitle = 'Describe in text';
  static const String textCardSubtitle = 'Type what you ate — quick and simple';

  static const String disclaimerLine1 = 'Approximate meal-level feedback.';
  static const String disclaimerLine2 =
      'Not medical advice or precise nutrient calculation.';

  static const String photoCardAsset = 'assets/images/meal_photo_card.png';
  static const String textIconAsset = 'assets/images/describe_text_icon.png';

  // 颜色
  static const Color backgroundColor = Color(0xFFF6FAF0);
  static const Color backColor = Color(0xFF1A6731);
  static const Color titleColor = Color(0xB3000000);
  static const Color subtitleColor = Color(0x99000000);
  static const Color photoSubtitleColor = Color(0x5C000000);
  static const Color cardTitleColor = Color(0xFF155327);
  static const Color photoIconColor = Color(0xFF0F6B35);
  static const Color textCardBg = Color(0xFFE3F3E1);
  static const Color textCardBorder = Color(0xA6082310);
  static const Color textCardSubtitleColor = Color(0xFF9CAA9B);
  static const Color disclaimerColor = Color(0xFF8A8C88);
  static const Color photoCardBorder = Color(0xFFE8EEE8);

  static const double subtitleFontSize = 13;
  static const double cardTitleFontSize = 19;
  static const double cardSubtitleFontSize = 12;

  /// 两个选项卡片尺寸
  static const double optionCardHeight = 148;
  static const double textCardHeight = 128;
  static const double optionCardRadius = 18;
  static const double optionCardPaddingH = 16;
  static const double optionCardPaddingV = 12;
  static const double optionIconSize = 32;
  static const double optionIconToTitleGap = 6;
  static const double optionSubtitleBottomPadding = 14;
  static const double textCardSubtitleBottomPadding = 20;

  // 页面布局
  static const double horizontalPadding = 24;
  static const double topExtraPadding = 48;
  static const double backToTitleGap = 18;
  static const double titleToSubtitleGap = 14;
  static const double titleToCardsGap = 28;
  static const double cardGap = 12;

  static const int disclaimerTopFlex = 4;
  static const int disclaimerBottomFlex = 3;
}
