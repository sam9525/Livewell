class Medication {
  final String? id; // Optional - provided by database for existing records
  final String name;
  final int dosage;
  final String dosageUnit;
  final String frequency;
  final String time;
  final DateTime startDate;
  final int? durationDays;
  final String notes;

  // Backend field name constants
  static const String _fieldId = 'id';
  static const String _fieldName = 'name';
  static const String _fieldDosageValue = 'dosageValue';
  static const String _fieldDosageUnit = 'dosageUnit';
  static const String _fieldFrequencyType = 'frequencyType';
  static const String _fieldFrequencyTime = 'frequencyTime';
  static const String _fieldStartDate = 'startDate';
  static const String _fieldDurationDays = 'durationDays';
  static const String _fieldNotes = 'notes';

  const Medication({
    this.id, // Optional for new medications, required for updates
    required this.name,
    required this.dosage,
    required this.dosageUnit,
    required this.frequency,
    required this.time,
    required this.startDate,
    this.durationDays,
    required this.notes,
  });

  // Helper method to build common map fields
  Map<String, dynamic> _buildBaseMap() {
    return {
      _fieldName: name,
      _fieldDosageValue: dosage,
      _fieldDosageUnit: dosageUnit,
      _fieldFrequencyType: frequency,
      _fieldFrequencyTime: time,
      _fieldStartDate: _formatDate(startDate),
      _fieldDurationDays: durationDays,
      _fieldNotes: notes,
    };
  }

  // Format date to backend format (YYYY-MM-DD)
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // Convert to Map for storage (includes id for updates)
  Map<String, dynamic> toMap() {
    final map = _buildBaseMap();
    if (id != null) {
      map[_fieldId] = id;
    }
    return map;
  }

  // Convert to Map for creating new medication (explicitly excludes ID)
  Map<String, dynamic> toCreateMap() => _buildBaseMap();

  // Create from Map (receives id from database)
  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map[_fieldId]?.toString(),
      name: (map[_fieldName] ?? '').toString(),
      dosage: (map[_fieldDosageValue] ?? 0).toInt(),
      dosageUnit: (map[_fieldDosageUnit] ?? '').toString(),
      frequency: (map[_fieldFrequencyType] ?? '').toString(),
      time: (map[_fieldFrequencyTime] ?? '').toString(),
      startDate: DateTime.parse(
        map[_fieldStartDate] ?? DateTime.now().toIso8601String(),
      ),
      durationDays: map[_fieldDurationDays] != null
          ? (map[_fieldDurationDays] is int
              ? map[_fieldDurationDays]
              : int.tryParse(map[_fieldDurationDays].toString()))
          : null,
      notes: (map[_fieldNotes] ?? '').toString(),
    );
  }

  // Copy with method for updates
  Medication copyWith({
    String? id,
    String? name,
    double? dosage,
    String? dosageUnit,
    String? frequency,
    String? time,
    DateTime? startDate,
    int? durationDays,
    String? notes,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage?.toInt() ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      notes: notes ?? this.notes,
    );
  }
}

// Enum for dosage units
enum DosageUnit {
  mg('mg'),
  ml('ml'),
  tablets('tablets');

  const DosageUnit(this.value);
  final String value;
}

// Enum for frequency
enum Frequency {
  daily('Daily'),
  twiceDaily('Twice a day'),
  weekly('Weekly');

  const Frequency(this.value);
  final String value;
}
