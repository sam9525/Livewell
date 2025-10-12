class Vaccination {
  final String id;
  final String name;
  final DateTime doseDate;
  final DateTime? nextDoseDate;
  final String location;
  final String notes;
  final DateTime createdAt;

  Vaccination({
    required this.id,
    required this.name,
    required this.doseDate,
    this.nextDoseDate,
    required this.location,
    required this.notes,
    required this.createdAt,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'doseDate': doseDate.toIso8601String(),
      'nextDoseDate': nextDoseDate?.toIso8601String(),
      'location': location,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory Vaccination.fromMap(Map<String, dynamic> map) {
    return Vaccination(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      doseDate: DateTime.parse(map['doseDate']),
      nextDoseDate: map['nextDoseDate'] != null
          ? DateTime.parse(map['nextDoseDate'])
          : null,
      location: map['location'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Copy with method for updates
  Vaccination copyWith({
    String? id,
    String? name,
    DateTime? doseDate,
    DateTime? nextDoseDate,
    String? location,
    String? notes,
    DateTime? createdAt,
  }) {
    return Vaccination(
      id: id ?? this.id,
      name: name ?? this.name,
      doseDate: doseDate ?? this.doseDate,
      nextDoseDate: nextDoseDate ?? this.nextDoseDate,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
