class Recommendation {
  final String recommendId;
  final String title;
  final String description;
  final int stepsTarget;
  final int waterIntakeTarget;
  final bool alreadySet;
  final DateTime? createdAt;

  // Backend field name constants
  static const String _fieldId = 'recommend_id';
  static const String _fieldTitle = 'title';
  static const String _fieldDescription = 'description';
  static const String _fieldStepsTarget = 'steps_target';
  static const String _fieldWaterIntakeTarget = 'water_intake_ml_target';
  static const String _fieldAlreadySet = 'already_set';
  static const String _fieldCreatedAt = 'created_at';

  const Recommendation({
    required this.recommendId,
    required this.title,
    required this.description,
    required this.stepsTarget,
    required this.waterIntakeTarget,
    required this.alreadySet,
    this.createdAt,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      _fieldId: recommendId,
      _fieldTitle: title,
      _fieldDescription: description,
      _fieldStepsTarget: stepsTarget,
      _fieldWaterIntakeTarget: waterIntakeTarget,
      _fieldAlreadySet: alreadySet.toString(),
      _fieldCreatedAt: createdAt?.toIso8601String(),
    };
  }

  // Create from Map (receives data from backend)
  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      recommendId: (map[_fieldId] ?? '').toString(),
      title: (map[_fieldTitle] ?? '').toString(),
      description: (map[_fieldDescription] ?? '').toString(),
      stepsTarget: (map[_fieldStepsTarget] ?? 0).toInt(),
      waterIntakeTarget: (map[_fieldWaterIntakeTarget] ?? 0).toInt(),
      alreadySet: _parseBool(map[_fieldAlreadySet]),
      createdAt: _parseDateTime(map[_fieldCreatedAt]),
    );
  }

  // Helper method to parse boolean from various types
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  // Helper method to parse DateTime from various types
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Copy with method for updates
  Recommendation copyWith({
    String? recommendId,
    String? title,
    String? description,
    int? stepsTarget,
    int? waterIntakeTarget,
    bool? alreadySet,
    DateTime? createdAt,
  }) {
    return Recommendation(
      recommendId: recommendId ?? this.recommendId,
      title: title ?? this.title,
      description: description ?? this.description,
      stepsTarget: stepsTarget ?? this.stepsTarget,
      waterIntakeTarget: waterIntakeTarget ?? this.waterIntakeTarget,
      alreadySet: alreadySet ?? this.alreadySet,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Check if recommendation is for today
  bool isForToday() {
    if (createdAt == null) {
      return true; // Show if no date (backward compatibility)
    }
    final now = DateTime.now();
    return createdAt!.year == now.year &&
        createdAt!.month == now.month &&
        createdAt!.day == now.day;
  }
}
