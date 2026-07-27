import 'package:flutter/material.dart';

import 'coaching_preferences_constants.dart';

/// Icon for each health / meal-focus chip (Material icons, app-wide consistent).
IconData mealFocusIconFor(String label) {
  switch (label) {
    case CoachingPreferencesConstants.focusNone:
      return Icons.check_circle_outline_rounded;
    case CoachingPreferencesConstants.focusDiabetes:
      return Icons.water_drop_outlined;
    case CoachingPreferencesConstants.focusBloodPressure:
      return Icons.favorite_border_rounded;
    case CoachingPreferencesConstants.focusCholesterol:
      return Icons.opacity_rounded;
    case CoachingPreferencesConstants.focusOther:
      return Icons.notes_rounded;
    default:
      return Icons.health_and_safety_outlined;
  }
}
