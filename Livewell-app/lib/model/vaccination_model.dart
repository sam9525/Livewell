class Vaccination {
  final String vacId;
  final String name;
  final DateTime doseDate;
  final DateTime? nextDoseDate;
  final String? location;
  final String? notes;

  // Backend field name constants
  static const String _fieldId = 'vac_id';
  static const String _fieldName = 'name';
  static const String _fieldDoseDate = 'dose_date';
  static const String _fieldNextDoseDate = 'next_dose_date';
  static const String _fieldLocation = 'location';
  static const String _fieldNotes = 'notes';

  const Vaccination({
    required this.vacId,
    required this.name,
    required this.doseDate,
    this.nextDoseDate,
    required this.location,
    required this.notes,
  });

  // Helper method to build common map fields
  Map<String, dynamic> _buildBaseMap() {
    return {
      _fieldName: name,
      _fieldDoseDate: _formatDate(doseDate),
      _fieldNextDoseDate: nextDoseDate != null
          ? _formatDate(nextDoseDate!)
          : null,
      _fieldLocation: location,
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
    map[_fieldId] = vacId;
    return map;
  }

  // Convert to Map for creating new vaccination (explicitly excludes ID)
  Map<String, dynamic> toCreateMap() => _buildBaseMap();

  // Create from Map (receives id from database)
  factory Vaccination.fromMap(Map<String, dynamic> map) {
    return Vaccination(
      vacId: map[_fieldId].toString(),
      name: (map[_fieldName] ?? '').toString(),
      doseDate: DateTime.parse(
        map[_fieldDoseDate] ?? DateTime.now().toIso8601String(),
      ),
      nextDoseDate: map[_fieldNextDoseDate] != null
          ? DateTime.parse(map[_fieldNextDoseDate])
          : null,
      location: (map[_fieldLocation] ?? '').toString(),
      notes: (map[_fieldNotes] ?? '').toString(),
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
  }) {
    return Vaccination(
      vacId: vacId,
      name: name ?? this.name,
      doseDate: doseDate ?? this.doseDate,
      nextDoseDate: nextDoseDate ?? this.nextDoseDate,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }
}
