class ChildModel {
  final String id;
  final String name;
  final DateTime birthDate;
  final String gender; // 'male' | 'female' | 'other'
  final String? photoUrl;
  final String? notes;

  const ChildModel({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.photoUrl,
    this.notes,
  });

  /// Age in completed months from today
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) months--;
    return months < 0 ? 0 : months;
  }

  /// Age in completed years from today
  int get ageInYears {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  /// Human-readable age string e.g. "2 years 3 months" or "5 months"
  String get ageString {
    final totalMonths = ageInMonths;
    if (totalMonths < 1) {
      final days = DateTime.now().difference(birthDate).inDays;
      return '$days days';
    }
    if (totalMonths < 12) return '$totalMonths month${totalMonths == 1 ? '' : 's'}';
    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;
    if (months == 0) return '$years year${years == 1 ? '' : 's'}';
    return '$years year${years == 1 ? '' : 's'} $months month${months == 1 ? '' : 's'}';
  }

  ChildModel copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? photoUrl,
    String? notes,
  }) {
    return ChildModel(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'photoUrl': photoUrl,
      'notes': notes,
    };
  }

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String,
      photoUrl: json['photoUrl'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  String toString() => 'ChildModel(id: $id, name: $name, age: $ageString)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
