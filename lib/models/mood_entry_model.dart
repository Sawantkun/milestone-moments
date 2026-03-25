enum MoodLevel { awful, sad, okay, good, great }

extension MoodLevelExtension on MoodLevel {
  String get displayName {
    switch (this) {
      case MoodLevel.awful:
        return 'Awful';
      case MoodLevel.sad:
        return 'Sad';
      case MoodLevel.okay:
        return 'Okay';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.great:
        return 'Great';
    }
  }

  String get emoji {
    switch (this) {
      case MoodLevel.awful:
        return '😢';
      case MoodLevel.sad:
        return '😕';
      case MoodLevel.okay:
        return '😐';
      case MoodLevel.good:
        return '😊';
      case MoodLevel.great:
        return '😄';
    }
  }

  int get value {
    switch (this) {
      case MoodLevel.awful:
        return 1;
      case MoodLevel.sad:
        return 2;
      case MoodLevel.okay:
        return 3;
      case MoodLevel.good:
        return 4;
      case MoodLevel.great:
        return 5;
    }
  }
}

class MoodEntry {
  final String id;
  final String childId;
  final DateTime date;
  final MoodLevel mood;
  final String? notes;
  final List<String> activities;

  const MoodEntry({
    required this.id,
    required this.childId,
    required this.date,
    required this.mood,
    this.notes,
    this.activities = const [],
  });

  MoodEntry copyWith({
    String? id,
    String? childId,
    DateTime? date,
    MoodLevel? mood,
    String? notes,
    List<String>? activities,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'date': date.toIso8601String(),
      'mood': mood.name,
      'notes': notes,
      'activities': activities,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      childId: json['childId'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: MoodLevel.values.firstWhere(
        (e) => e.name == json['mood'],
        orElse: () => MoodLevel.okay,
      ),
      notes: json['notes'] as String?,
      activities: List<String>.from(json['activities'] as List? ?? []),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
