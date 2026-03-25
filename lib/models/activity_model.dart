class ActivityModel {
  final String id;
  final String title;
  final String description;
  final int ageMinMonths;
  final int ageMaxMonths;
  final String category;
  final int durationMinutes;
  final List<String> materials;
  final List<String> benefits;
  bool isDone;

  ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ageMinMonths,
    required this.ageMaxMonths,
    required this.category,
    required this.durationMinutes,
    this.materials = const [],
    this.benefits = const [],
    this.isDone = false,
  });

  ActivityModel copyWith({
    String? id,
    String? title,
    String? description,
    int? ageMinMonths,
    int? ageMaxMonths,
    String? category,
    int? durationMinutes,
    List<String>? materials,
    List<String>? benefits,
    bool? isDone,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ageMinMonths: ageMinMonths ?? this.ageMinMonths,
      ageMaxMonths: ageMaxMonths ?? this.ageMaxMonths,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      materials: materials ?? this.materials,
      benefits: benefits ?? this.benefits,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ageMinMonths': ageMinMonths,
      'ageMaxMonths': ageMaxMonths,
      'category': category,
      'durationMinutes': durationMinutes,
      'materials': materials,
      'benefits': benefits,
      'isDone': isDone,
    };
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      ageMinMonths: json['ageMinMonths'] as int,
      ageMaxMonths: json['ageMaxMonths'] as int,
      category: json['category'] as String,
      durationMinutes: json['durationMinutes'] as int,
      materials: List<String>.from(json['materials'] as List? ?? []),
      benefits: List<String>.from(json['benefits'] as List? ?? []),
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
