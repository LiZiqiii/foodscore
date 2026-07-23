/// Weekly Reflection 展示用格式化（日期、餐段）。
abstract final class WeeklyReflectionFormat {
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// 例如 `Monday · Lunch`。
  static String dayAndTime(DateTime savedAt) {
    final weekday = _weekdays[savedAt.weekday - 1];
    return '$weekday · ${_mealSlot(savedAt.hour)}';
  }

  static String _mealSlot(int hour) {
    if (hour >= 5 && hour < 11) {
      return 'Breakfast';
    }
    if (hour >= 11 && hour < 15) {
      return 'Lunch';
    }
    if (hour >= 17 && hour < 22) {
      return 'Dinner';
    }
    return 'Snack';
  }
}
