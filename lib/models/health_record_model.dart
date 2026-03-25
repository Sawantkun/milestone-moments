class HealthRecord {
  final String id;
  final String childId;
  final DateTime date;
  final double? heightCm;
  final double? weightKg;
  final double? headCircumferenceCm;
  final String? notes;

  const HealthRecord({
    required this.id,
    required this.childId,
    required this.date,
    this.heightCm,
    this.weightKg,
    this.headCircumferenceCm,
    this.notes,
  });

  HealthRecord copyWith({
    String? id,
    String? childId,
    DateTime? date,
    double? heightCm,
    double? weightKg,
    double? headCircumferenceCm,
    String? notes,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      date: date ?? this.date,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      headCircumferenceCm: headCircumferenceCm ?? this.headCircumferenceCm,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'date': date.toIso8601String(),
      'heightCm': heightCm,
      'weightKg': weightKg,
      'headCircumferenceCm': headCircumferenceCm,
      'notes': notes,
    };
  }

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as String,
      childId: json['childId'] as String,
      date: DateTime.parse(json['date'] as String),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      headCircumferenceCm: (json['headCircumferenceCm'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthRecord && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
