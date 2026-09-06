
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

  static String dayAndTime(DateTime savedAt) {
    return _weekdays[savedAt.weekday - 1];
  }
}
