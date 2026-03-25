enum MilestoneCategory { motor, language, social, cognitive, other }

extension MilestoneCategoryExtension on MilestoneCategory {
  String get displayName {
    switch (this) {
      case MilestoneCategory.motor:
        return 'Motor';
      case MilestoneCategory.language:
        return 'Language';
      case MilestoneCategory.social:
        return 'Social';
      case MilestoneCategory.cognitive:
        return 'Cognitive';
      case MilestoneCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case MilestoneCategory.motor:
        return '🏃';
      case MilestoneCategory.language:
        return '💬';
      case MilestoneCategory.social:
        return '🤝';
      case MilestoneCategory.cognitive:
        return '🧠';
      case MilestoneCategory.other:
        return '⭐';
    }
  }
}

class MilestoneModel {
  final String id;
  final String childId;
  final String title;
  final String description;
  final DateTime date;
  final MilestoneCategory category;
  final String? photoUrl;

  const MilestoneModel({
    required this.id,
    required this.childId,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    this.photoUrl,
  });

  MilestoneModel copyWith({
    String? id,
    String? childId,
    String? title,
    String? description,
    DateTime? date,
    MilestoneCategory? category,
    String? photoUrl,
  }) {
    return MilestoneModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category.name,
      'photoUrl': photoUrl,
    };
  }

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      category: MilestoneCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MilestoneCategory.other,
      ),
      photoUrl: json['photoUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilestoneModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
