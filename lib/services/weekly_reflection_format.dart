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

  /// 例如 `Monday`。
  static String dayAndTime(DateTime savedAt) {
    return _weekdays[savedAt.weekday - 1];
  }
}
