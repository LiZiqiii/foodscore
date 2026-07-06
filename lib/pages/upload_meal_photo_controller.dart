import 'package:flutter/material.dart';

/// 上传餐食照片页控制器。
class UploadMealPhotoController {
  UploadMealPhotoController._();

  static const String backLabel = '<  Back';
  static const String title = 'Upload your meal photo';
  static const String subtitle = 'A clear top-down photo gives the best results. ';
  static const String uploadHint = 'Tap to choose in Photos or take photo';
  static const String descriptionLabel = 'Add a description ';
  static const String descriptionOptional = '(optional — improves accuracy)';
  static const String descriptionHint =
      'e.g. Grilled salmon with roasted broccoli and brown rice, with a lemon dressing.';
  static const String ctaLabel = 'Continue';
  static const String disclaimerLine1 = 'Approximate meal-level feedback.';
  static const String disclaimerLine2 =
      'Not medical advice or precise nutrient calculation.';

  // 颜色
  static const Color backgroundColor = Color(0xFFF6FAF0);
  static const Color backColor = Color(0xFF1A6731);
  static const Color titleColor = Color(0xB3000000);
  static const Color subtitleColor = Color(0x73000000);
  static const Color uploadAreaBorder = Color(0xFFBFD6CC);
  /// #F4FFFE 67% 叠在 #F6FAF0 上的不透明等效色
  static const Color uploadAreaBg = Color(0xFFF5FDF9);
  static const Color uploadIconColor = Color(0xFF0F6B35);
  static const Color uploadHintColor = Color(0xF22E5E35);
  static const Color descriptionLabelColor = Color(0xFF4A4B48);
  static const Color descriptionOptionalColor = Color(0x73000000);
  static const Color descriptionInputBg = Color(0xFFFAFCFA);
  static const Color descriptionInputBorder = Color(0x0D082310);
  static const Color descriptionHintColor = Color(0xFF959694);
  static const Color descriptionTextColor = Color(0xFF4A4B48);
  static const Color ctaDisabledBg = Color(0xFFF5F5F5);
  static const Color ctaDisabledText = Color(0x2B1A6731);
  static const Color ctaEnabledBg = Color(0xFF1A6731);
  static const Color disclaimerColor = Color(0xFF8A8C88);

  // 尺寸
  static const double horizontalPadding = 24;
  static const double topExtraPadding = 10;
  static const double backToTitleGap = 18;
  static const double titleToSubtitleGap = 14;
  static const double subtitleToUploadGap = 28;
  static const double subtitleFontSize = 14;
  static const double uploadIconSize = 32;
  static const double uploadIconToHintGap = 15;
  static const double uploadAreaHeight = 130;
  static const double uploadAreaRadius = 12;
  static const double descriptionLabelToOptionalGap = 9;
  static const double optionalToInputGap = 7;
  static const double descriptionInputHeight = 88;
  static const double descriptionInputPaddingH = 14;
  static const double descriptionInputPaddingV = 10;
  static const double descriptionInputFontSize = 14;
  static const double descriptionInputLineHeight = 25 / 14;
  static const double descriptionInputRadiusTL = 16;
  static const double descriptionInputRadiusTR = 19;
  static const double descriptionInputRadiusBL = 18;
  static const double descriptionInputRadiusBR = 25;
  static const double descriptionToCtaGap = 32;
  static const double ctaToDisclaimerGap = 44;
  static const double disclaimerBottomPadding = 24;

  // CTA — 与 home page 一致
  static const double ctaHeight = 48;
  static const double ctaRadius = 15;
  static const double ctaFontSize = 16;
  static const double ctaIconSize = 18;
  static const double ctaIconGap = 6;
}
