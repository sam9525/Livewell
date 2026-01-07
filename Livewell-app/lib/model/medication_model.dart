class Medication {
  final String medId;
  final String name;
  final int dosage;
  final String dosageUnit;
  final String frequency;
  final String time;
  final DateTime startDate;
  final int? durationDays;
  final String? notes;

  // Backend field name constants
  static const String _fieldMedId = 'med_id';
  static const String _fieldName = 'name';
  static const String _fieldDosageValue = 'dose_value';
  static const String _fieldDosageUnit = 'dose_unit';
  static const String _fieldFrequencyType = 'frequency_type';
  static const String _fieldFrequencyTime = 'frequency_time';
  static const String _fieldStartDate = 'start_date';
  static const String _fieldDurationDays = 'durations';
  static const String _fieldNotes = 'notes';

  const Medication({
    required this.medId,
    required this.name,
    required this.dosage,
    required this.dosageUnit,
    required this.frequency,
    required this.time,
    required this.startDate,
    this.durationDays,
    this.notes,
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
    map[_fieldMedId] = medId;
    return map;
  }

  // Convert to Map for creating new medication (explicitly excludes ID)
  Map<String, dynamic> toCreateMap() => _buildBaseMap();

  // Create from Map (receives id from database)
  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      medId: map[_fieldMedId].toString(),
      name: (map[_fieldName] ?? '').toString(),
      dosage: (map[_fieldDosageValue] ?? 0).toInt(),
      dosageUnit: (map[_fieldDosageUnit] ?? '').toString(),
      frequency: (map[_fieldFrequencyType] ?? '').toString(),
      time: (map[_fieldFrequencyTime] ?? '').toString(),
      startDate: DateTime.parse(
        map[_fieldStartDate] ?? DateTime.now().toIso8601String(),
      ),
      durationDays: map[_fieldDurationDays] != ''
          ? (map[_fieldDurationDays] is int
                ? map[_fieldDurationDays]
                : int.tryParse(map[_fieldDurationDays].toString()))
          : null,
      notes: (map[_fieldNotes] ?? '').toString(),
    );
  }

  // Copy with method for updates
  Medication copyWith({
    String? medId,
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
      medId: medId ?? this.medId,
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
