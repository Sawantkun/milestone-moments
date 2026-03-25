enum ReminderType { vaccination, checkup, other }

extension ReminderTypeExtension on ReminderType {
  String get displayName {
    switch (this) {
      case ReminderType.vaccination:
        return 'Vaccination';
      case ReminderType.checkup:
        return 'Check-up';
      case ReminderType.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case ReminderType.vaccination:
        return '💉';
      case ReminderType.checkup:
        return '🏥';
      case ReminderType.other:
        return '🔔';
    }
  }
}

class ReminderModel {
  final String id;
  final String childId;
  final String title;
  final String description;
  final DateTime dateTime;
  final ReminderType type;
  final bool isCompleted;

  const ReminderModel({
    required this.id,
    required this.childId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
    this.isCompleted = false,
  });

  ReminderModel copyWith({
    String? id,
    String? childId,
    String? title,
    String? description,
    DateTime? dateTime,
    ReminderType? type,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'type': type.name,
      'isCompleted': isCompleted,
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.other,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
