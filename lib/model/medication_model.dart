class Medication {
  final String id;
  final String name;
  final double dosage;
  final String dosageUnit;
  final String frequency;
  final String time;
  final DateTime startDate;
  final int? durationDays;
  final String notes;
  final DateTime createdAt;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.dosageUnit,
    required this.frequency,
    required this.time,
    required this.startDate,
    this.durationDays,
    required this.notes,
    required this.createdAt,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'dosageUnit': dosageUnit,
      'frequency': frequency,
      'time': time,
      'startDate': startDate.toIso8601String(),
      'durationDays': durationDays,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dosage: (map['dosage'] ?? 0).toDouble(),
      dosageUnit: map['dosageUnit'] ?? '',
      frequency: map['frequency'] ?? '',
      time: map['time'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      durationDays: map['durationDays'],
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
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
    DateTime? createdAt,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
