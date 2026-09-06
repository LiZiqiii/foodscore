/// Shared health considerations for sign-up and Coaching Profile.

abstract final class CoachingPreferencesConstants {
  static const String focusNone = 'None';

  static const String focusDiabetes = 'Diabetes or prediabetes';

  static const String focusBloodPressure = 'High blood pressure';

  static const String focusCholesterol = 'High cholesterol';

  static const String focusOther = 'Other';

  static const String healthConsiderationsLabel = 'Health considerations';

  static const String aboutYouSection = 'About you';
  static const String ageLabel = 'Age';
  static const String ageRangePlaceholder = 'Select age range';
  static const String heightHint = 'Height cm';
  static const String weightHint = 'Weight kg';

  static const List<String> ageRangeOptions = [
    'Under 18',
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55-64',
    '65+',
    'Prefer not to say',
  ];

  static const List<String> mealFocusOptions = [
    focusNone,

    focusDiabetes,

    focusBloodPressure,

    focusCholesterol,

    focusOther,
  ];

  static const String otherNoteHint = 'Brief note';

  static const int otherNoteMaxLength = 48;

  static const Set<String> _storedConditionLabels = {
    focusDiabetes,

    focusBloodPressure,

    focusCholesterol,
  };

  /// Maps stored profile values to current chip labels.

  static String? normalizeMealFocusLabel(String raw) {
    final trimmed = raw.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    final key = trimmed.toLowerCase();

    if (key == 'prefer not to say') {
      return null;
    }

    if (key == 'none') {
      return focusNone;
    }

    for (final option in mealFocusOptions) {
      if (option.toLowerCase() == key) {
        return option;
      }
    }

    if (key.contains('diabetes') ||
        key.contains('prediabetes') ||
        key.contains('blood sugar')) {
      return focusDiabetes;
    }

    if (key.contains('blood pressure') ||
        key.contains('hypertension') ||
        key.contains('lower salt') ||
        key.contains('lower-salt')) {
      return focusBloodPressure;
    }

    if (key.contains('cholesterol')) {
      return focusCholesterol;
    }

    if (key == 'other' || key.contains('other health')) {
      return focusOther;
    }

    return trimmed;
  }

  static Set<String> mealFocusFromProfile({
    required List<String> healthConditions,

    required String? healthContext,

    required String? healthOtherNote,
  }) {
    final selected = <String>{};

    void addRaw(String? raw) {
      if (raw == null || raw.isEmpty) {
        return;
      }

      for (final part in raw.split(',')) {
        final normalized = normalizeMealFocusLabel(part);

        if (normalized == null) {
          continue;
        }

        if (normalized == focusNone) {
          selected.add(focusNone);
        } else if (normalized == focusOther) {
          selected.add(focusOther);
        } else if (mealFocusOptions.contains(normalized)) {
          selected.add(normalized);
        } else {
          selected.add(focusOther);
        }
      }
    }

    for (final item in healthConditions) {
      addRaw(item);
    }

    addRaw(healthContext);

    final note = healthOtherNote?.trim();

    if (note != null && note.isNotEmpty) {
      selected.add(focusOther);
    }

    if (selected.isEmpty) {
      selected.add(focusNone);
    }

    return selected;
  }

  static String? otherNoteFromProfile({
    required List<String> healthConditions,

    required String? healthOtherNote,
  }) {
    final note = healthOtherNote?.trim();

    if (note != null && note.isNotEmpty) {
      return note;
    }

    for (final item in healthConditions) {
      final normalized = normalizeMealFocusLabel(item);

      if (normalized != null &&
          normalized != focusNone &&
          !_storedConditionLabels.contains(normalized) &&
          normalized != focusOther) {
        return normalized;
      }
    }

    return null;
  }

  /// Conditions persisted to the API.

  static List<String> conditionsForSave(Set<String> selected) {
    return selected
        .where(
          (label) =>
              label != focusNone &&
              label != focusOther &&
              _storedConditionLabels.contains(label),
        )
        .toList(growable: false);
  }

  static void toggleMealFocus(Set<String> selected, String label) {
    if (label == focusNone) {
      if (selected.contains(focusNone)) {
        selected.remove(focusNone);
      } else {
        selected
          ..clear()
          ..add(focusNone);
      }

      return;
    }

    selected.remove(focusNone);

    if (label == focusOther) {
      if (selected.contains(focusOther)) {
        selected.remove(focusOther);
      } else {
        selected.add(focusOther);
      }

      return;
    }

    if (selected.contains(label)) {
      selected.remove(label);
    } else {
      selected.add(label);
    }
  }
}
