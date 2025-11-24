class Recommendation {
  final String id;
  final String title;
  final String message;
  final int stepsTarget;
  final int waterIntakeTarget;
  final bool isCompleted;
  final DateTime? createdAt;

  // Backend field name constants
  static const String _fieldId = 'id';
  static const String _fieldTitle = 'title';
  static const String _fieldMessage = 'message';
  static const String _fieldStepsTarget = 'stepsTarget';
  static const String _fieldWaterIntakeTarget = 'waterIntakeTarget';
  static const String _fieldIsCompleted = 'isCompleted';
  static const String _fieldCreatedAt = 'createdAt';

  const Recommendation({
    required this.id,
    required this.title,
    required this.message,
    required this.stepsTarget,
    required this.waterIntakeTarget,
    required this.isCompleted,
    this.createdAt,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      _fieldId: id,
      _fieldTitle: title,
      _fieldMessage: message,
      _fieldStepsTarget: stepsTarget,
      _fieldWaterIntakeTarget: waterIntakeTarget,
      _fieldIsCompleted: isCompleted.toString(),
      _fieldCreatedAt: createdAt?.toIso8601String(),
    };
  }

  // Create from Map (receives data from backend)
  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: (map[_fieldId] ?? '').toString(),
      title: (map[_fieldTitle] ?? '').toString(),
      message: (map[_fieldMessage] ?? '').toString(),
      stepsTarget: (map[_fieldStepsTarget] ?? 0).toInt(),
      waterIntakeTarget: (map[_fieldWaterIntakeTarget] ?? 0).toInt(),
      isCompleted: _parseBool(map[_fieldIsCompleted]),
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
    String? id,
    String? title,
    String? message,
    int? stepsTarget,
    int? waterIntakeTarget,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Recommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      stepsTarget: stepsTarget ?? this.stepsTarget,
      waterIntakeTarget: waterIntakeTarget ?? this.waterIntakeTarget,
      isCompleted: isCompleted ?? this.isCompleted,
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
