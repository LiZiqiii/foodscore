import 'package:flutter/material.dart';

import '../coaching/coaching_preferences_constants.dart';

/// Coaching Profile 页文案、选项与样式。
class CoachingProfilePageController {
  CoachingProfilePageController._();

  static const String title = 'Coaching Profile';
  static const String explanation =
      'Helps FoodScore tailor meal coaching—not medical advice.';

  static const String aboutYouSection =
      CoachingPreferencesConstants.aboutYouSection;
  static const String ageLabel = CoachingPreferencesConstants.ageLabel;
  static const String heightHint = CoachingPreferencesConstants.heightHint;
  static const String weightHint = CoachingPreferencesConstants.weightHint;
  static const String mealFocusLabel =
      CoachingPreferencesConstants.healthConsiderationsLabel;

  static const String ageRangePlaceholder =
      CoachingPreferencesConstants.ageRangePlaceholder;

  static const List<String> ageRangeOptions =
      CoachingPreferencesConstants.ageRangeOptions;

  static const String saveButton = 'Save';
  static const String loadFailedMessage =
      'Could not load your coaching profile. Please try again.';
  static const String saveFailedMessage =
      'Could not save your coaching profile. Please try again.';
  static const String saveSuccessMessage = 'Coaching profile saved.';

  static const Color chipBg = Color(0xFFE1F4F0);
  static const Color chipBgSelected = Color(0xFF1A6731);
  static const Color chipText = Color(0xFF3D6C47);
  static const Color chipTextSelected = Color(0xFFFFFFFF);
  static const double chipFontSize = 13;
  static const double chipHeight = 32;
  static const double chipGap = 8;

  static const Color bgTop = Color(0xFFFFFFFF);
  static const Color bgMid = Color(0xFFF4FBF2);
  static const Color bgBottom = Color(0xFFE8F6E4);
  static const Color titleColor = Color(0xFF1B5E32);
  static const Color bodyTextColor = Color(0xFF4A4B48);
  static const Color subtitleLabelColor = Color(0xFF6B6F6B);
  static const Color hintColor = Color(0xFFA8A8A8);
  static const Color inputTextColor = Color(0xFF2C2C2C);
  static const Color inputBackgroundColor = Color(0xFFFFFFFF);
  static const Color inputBorderColor = Color(0xFFDCE8DC);
  static const Color errorTextColor = Color(0xFFC62828);
  static const Color buttonColor = Color(0xFF7FCB8F);
  static const Color buttonTextColor = Color(0xFF134026);

  static const double horizontalPadding = 28;
  static const double topInset = 16;
  static const double backToTitleGap = 20;
  static const double titleFontSize = 26;
  static const double bodyFontSize = 14;
  static const double labelFontSize = 14;
  static const double inputFontSize = 15;
  static const double buttonFontSize = 17;
  static const double errorFontSize = 12;
  static const double titleToExplanationGap = 12;
  static const double explanationToFormGap = 22;
  static const double fieldGap = 12;
  static const double labelGap = 8;
  static const double formToButtonGap = 26;
  static const double inputHeight = 46;
  static const double inputBorderRadius = 12;
  static const double buttonHeight = 50;
  static const double buttonBorderRadius = 14;
  static const double buttonElevation = 4;
}
