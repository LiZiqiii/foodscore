/// Weekly Reflection 页 Weekly Summary 区块数据。
class WeeklyReflectionSummary {
  const WeeklyReflectionSummary({
    required this.goodPatterns,
    required this.smallFocus,
  });

  final List<String> goodPatterns;
  final List<String> smallFocus;

  static const empty = WeeklyReflectionSummary(
    goodPatterns: [],
    smallFocus: [],
  );

  factory WeeklyReflectionSummary.fromJson(Map<String, dynamic> json) {
    return WeeklyReflectionSummary(
      goodPatterns: _stringList(json['goodPatterns']),
      smallFocus: _stringList(json['smallFocus']),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
