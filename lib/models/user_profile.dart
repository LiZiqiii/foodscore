/// Coaching profile payload aligned with FastAPI `/user-profile`.
class UserProfile {
  const UserProfile({
    required this.userId,
    this.ageRange,
    this.heightCm,
    this.weightKg,
    this.dietaryPreference,
    this.healthContext,
    this.healthConditions = const [],
    this.healthOtherNote,
    this.updatedAt,
  });

  factory UserProfile.empty(String userId) {
    return UserProfile(userId: userId);
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final conditionsRaw = json['healthConditions'];
    final conditions = <String>[];
    if (conditionsRaw is List) {
      for (final item in conditionsRaw) {
        final text = item?.toString().trim();
        if (text != null && text.isNotEmpty) {
          conditions.add(text);
        }
      }
    }

    return UserProfile(
      userId: json['userId']?.toString() ?? '',
      ageRange: _optionalString(json['ageRange']),
      heightCm: _optionalString(json['heightCm']),
      weightKg: _optionalString(json['weightKg']),
      dietaryPreference: _optionalString(json['dietaryPreference']),
      healthContext: _optionalString(json['healthContext']),
      healthConditions: conditions,
      healthOtherNote: _optionalString(json['healthOtherNote']),
      updatedAt: _optionalString(json['updatedAt']),
    );
  }

  final String userId;
  final String? ageRange;
  final String? heightCm;
  final String? weightKg;
  final String? dietaryPreference;
  final String? healthContext;
  final List<String> healthConditions;
  final String? healthOtherNote;
  final String? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (ageRange != null && ageRange!.isNotEmpty) 'ageRange': ageRange,
      if (heightCm != null && heightCm!.isNotEmpty) 'heightCm': heightCm,
      if (weightKg != null && weightKg!.isNotEmpty) 'weightKg': weightKg,
      'dietaryPreference': dietaryPreference,
      'healthContext': healthContext,
      'healthConditions': healthConditions,
      if (healthOtherNote != null && healthOtherNote!.isNotEmpty)
        'healthOtherNote': healthOtherNote,
    };
  }

  static String? _optionalString(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
