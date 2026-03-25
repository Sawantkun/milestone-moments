import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/child_model.dart';
import '../models/milestone_model.dart';
import '../models/health_record_model.dart';
import '../models/mood_entry_model.dart';
import '../models/reminder_model.dart';

class StorageService {
  static const String _childrenKey = 'mm_children';
  static const String _milestonesKey = 'mm_milestones';
  static const String _healthRecordsKey = 'mm_health_records';
  static const String _moodEntriesKey = 'mm_mood_entries';
  static const String _remindersKey = 'mm_reminders';
  static const String _seededKey = 'mm_seeded';
  static const _uuid = Uuid();

  // ---------------------------------------------------------------------------
  // Children
  // ---------------------------------------------------------------------------

  Future<List<ChildModel>> getChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_childrenKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => ChildModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveChild(ChildModel child) async {
    final children = await getChildren();
    final idx = children.indexWhere((c) => c.id == child.id);
    if (idx >= 0) {
      children[idx] = child;
    } else {
      children.add(child);
    }
    await _persistChildren(children);
  }

  Future<void> deleteChild(String childId) async {
    final children = await getChildren();
    children.removeWhere((c) => c.id == childId);
    await _persistChildren(children);
    // Cascade delete
    await deleteMilestonesForChild(childId);
    await deleteHealthRecordsForChild(childId);
    await deleteMoodEntriesForChild(childId);
    await deleteRemindersForChild(childId);
  }

  Future<void> _persistChildren(List<ChildModel> children) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _childrenKey,
      jsonEncode(children.map((c) => c.toJson()).toList()),
    );
  }

  // ---------------------------------------------------------------------------
  // Milestones
  // ---------------------------------------------------------------------------

  Future<List<MilestoneModel>> getMilestones({String? childId}) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_milestonesKey);
    if (json == null) return [];
    final list = (jsonDecode(json) as List)
        .map((e) => MilestoneModel.fromJson(e as Map<String, dynamic>))
        .toList();
    if (childId != null) return list.where((m) => m.childId == childId).toList();
    return list;
  }

  Future<void> saveMilestone(MilestoneModel milestone) async {
    final all = await getMilestones();
    final idx = all.indexWhere((m) => m.id == milestone.id);
    if (idx >= 0) {
      all[idx] = milestone;
    } else {
      all.add(milestone);
    }
    await _persistMilestones(all);
  }

  Future<void> deleteMilestone(String milestoneId) async {
    final all = await getMilestones();
    all.removeWhere((m) => m.id == milestoneId);
    await _persistMilestones(all);
  }

  Future<void> deleteMilestonesForChild(String childId) async {
    final all = await getMilestones();
    all.removeWhere((m) => m.childId == childId);
    await _persistMilestones(all);
  }

  Future<void> _persistMilestones(List<MilestoneModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _milestonesKey,
      jsonEncode(items.map((m) => m.toJson()).toList()),
    );
  }

  // ---------------------------------------------------------------------------
  // Health Records
  // ---------------------------------------------------------------------------

  Future<List<HealthRecord>> getHealthRecords({String? childId}) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_healthRecordsKey);
    if (json == null) return [];
    final list = (jsonDecode(json) as List)
        .map((e) => HealthRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    if (childId != null) return list.where((r) => r.childId == childId).toList();
    return list;
  }

  Future<void> saveHealthRecord(HealthRecord record) async {
    final all = await getHealthRecords();
    final idx = all.indexWhere((r) => r.id == record.id);
    if (idx >= 0) {
      all[idx] = record;
    } else {
      all.add(record);
    }
    await _persistHealthRecords(all);
  }

  Future<void> deleteHealthRecord(String recordId) async {
    final all = await getHealthRecords();
    all.removeWhere((r) => r.id == recordId);
    await _persistHealthRecords(all);
  }

  Future<void> deleteHealthRecordsForChild(String childId) async {
    final all = await getHealthRecords();
    all.removeWhere((r) => r.childId == childId);
    await _persistHealthRecords(all);
  }

  Future<void> _persistHealthRecords(List<HealthRecord> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _healthRecordsKey,
      jsonEncode(items.map((r) => r.toJson()).toList()),
    );
  }

  // ---------------------------------------------------------------------------
  // Mood Entries
  // ---------------------------------------------------------------------------

  Future<List<MoodEntry>> getMoodEntries({String? childId}) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_moodEntriesKey);
    if (json == null) return [];
    final list = (jsonDecode(json) as List)
        .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    if (childId != null) return list.where((m) => m.childId == childId).toList();
    return list;
  }

  Future<void> saveMoodEntry(MoodEntry entry) async {
    final all = await getMoodEntries();
    final idx = all.indexWhere((m) => m.id == entry.id);
    if (idx >= 0) {
      all[idx] = entry;
    } else {
      all.add(entry);
    }
    await _persistMoodEntries(all);
  }

  Future<void> deleteMoodEntry(String entryId) async {
    final all = await getMoodEntries();
    all.removeWhere((m) => m.id == entryId);
    await _persistMoodEntries(all);
  }

  Future<void> deleteMoodEntriesForChild(String childId) async {
    final all = await getMoodEntries();
    all.removeWhere((m) => m.childId == childId);
    await _persistMoodEntries(all);
  }

  Future<void> _persistMoodEntries(List<MoodEntry> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _moodEntriesKey,
      jsonEncode(items.map((m) => m.toJson()).toList()),
    );
  }

  // ---------------------------------------------------------------------------
  // Reminders
  // ---------------------------------------------------------------------------

  Future<List<ReminderModel>> getReminders({String? childId}) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_remindersKey);
    if (json == null) return [];
    final list = (jsonDecode(json) as List)
        .map((e) => ReminderModel.fromJson(e as Map<String, dynamic>))
        .toList();
    if (childId != null) return list.where((r) => r.childId == childId).toList();
    return list;
  }

  Future<void> saveReminder(ReminderModel reminder) async {
    final all = await getReminders();
    final idx = all.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) {
      all[idx] = reminder;
    } else {
      all.add(reminder);
    }
    await _persistReminders(all);
  }

  Future<void> deleteReminder(String reminderId) async {
    final all = await getReminders();
    all.removeWhere((r) => r.id == reminderId);
    await _persistReminders(all);
  }

  Future<void> deleteRemindersForChild(String childId) async {
    final all = await getReminders();
    all.removeWhere((r) => r.childId == childId);
    await _persistReminders(all);
  }

  Future<void> _persistReminders(List<ReminderModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _remindersKey,
      jsonEncode(items.map((r) => r.toJson()).toList()),
    );
  }

  // ---------------------------------------------------------------------------
  // Seed sample data
  // ---------------------------------------------------------------------------

  Future<bool> isSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seededKey) ?? false;
  }

  Future<void> seedSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seededKey) == true) return;

    final now = DateTime.now();

    // -- Children --
    const emmaId = 'child_emma_001';
    const noahId = 'child_noah_001';

    final emma = ChildModel(
      id: emmaId,
      name: 'Emma',
      birthDate: DateTime(2024, 3, 15),
      gender: 'female',
      notes: 'Loves music and dancing. Favourite toy is her stuffed bunny.',
    );

    final noah = ChildModel(
      id: noahId,
      name: 'Noah',
      birthDate: DateTime(2025, 10, 1),
      gender: 'male',
      notes: 'Very alert and curious. Loves tummy time.',
    );

    await saveChild(emma);
    await saveChild(noah);

    // -- Milestones for Emma --
    final emmaMilestones = [
      MilestoneModel(
        id: _uuid.v4(),
        childId: emmaId,
        title: 'First Word "Mama"',
        description: 'Emma said her first word "mama" clearly while looking at me. I cried happy tears!',
        date: DateTime(2024, 9, 5),
        category: MilestoneCategory.language,
      ),
      MilestoneModel(
        id: _uuid.v4(),
        childId: emmaId,
        title: 'Started Walking',
        description: 'Emma took her first independent steps across the living room — 5 steps in a row!',
        date: DateTime(2025, 1, 20),
        category: MilestoneCategory.motor,
      ),
      MilestoneModel(
        id: _uuid.v4(),
        childId: emmaId,
        title: 'Ate Solid Food',
        description: 'First taste of pureed sweet potato. She made the funniest face but kept opening her mouth for more.',
        date: DateTime(2024, 9, 15),
        category: MilestoneCategory.other,
      ),
      MilestoneModel(
        id: _uuid.v4(),
        childId: emmaId,
        title: 'First Sentence',
        description: 'Said "more milk please" — three words strung together for the first time!',
        date: DateTime(2025, 8, 3),
        category: MilestoneCategory.language,
      ),
      MilestoneModel(
        id: _uuid.v4(),
        childId: emmaId,
        title: 'Recognised Colours',
        description: 'Correctly identified red, blue, and yellow when asked. Such a clever girl!',
        date: DateTime(2025, 11, 10),
        category: MilestoneCategory.cognitive,
      ),
      MilestoneModel(
        id: _uuid.v4(),
        childId: emmaId,
        title: 'Waved Bye-Bye',
        description: 'Started waving goodbye spontaneously to daddy as he left for work.',
        date: DateTime(2024, 10, 2),
        category: MilestoneCategory.social,
      ),
    ];

    for (final m in emmaMilestones) {
      await saveMilestone(m);
    }

    // -- Milestones for Noah --
    final noahMilestones = [
      MilestoneModel(
        id: _uuid.v4(),
        childId: noahId,
        title: 'First Smile',
        description: 'Noah gave us his very first real social smile! Heart completely melted.',
        date: DateTime(2025, 11, 1),
        category: MilestoneCategory.social,
      ),
      MilestoneModel(
        id: _uuid.v4(),
        childId: noahId,
        title: 'Started Rolling Over',
        description: 'Rolled from tummy to back during tummy time. He seemed surprised himself!',
        date: DateTime(2026, 1, 14),
        category: MilestoneCategory.motor,
      ),
      MilestoneModel(
        id: _uuid.v4(),
        childId: noahId,
        title: 'Recognised Parents',
        description: 'Clearly turns head and smiles when he hears mama and daddy\'s voice. So precious.',
        date: DateTime(2025, 12, 5),
        category: MilestoneCategory.social,
      ),
    ];

    for (final m in noahMilestones) {
      await saveMilestone(m);
    }

    // -- Health Records for Emma --
    final emmaHealth = [
      HealthRecord(id: _uuid.v4(), childId: emmaId, date: DateTime(2024, 3, 15), heightCm: 49.5, weightKg: 3.2, headCircumferenceCm: 34.0, notes: 'Birth measurements'),
      HealthRecord(id: _uuid.v4(), childId: emmaId, date: DateTime(2024, 6, 15), heightCm: 62.0, weightKg: 6.5, headCircumferenceCm: 40.5, notes: '3-month check-up'),
      HealthRecord(id: _uuid.v4(), childId: emmaId, date: DateTime(2024, 9, 15), heightCm: 67.5, weightKg: 8.1, headCircumferenceCm: 43.0, notes: '6-month check-up'),
      HealthRecord(id: _uuid.v4(), childId: emmaId, date: DateTime(2024, 12, 15), heightCm: 72.0, weightKg: 9.2, headCircumferenceCm: 45.0, notes: '9-month check-up'),
      HealthRecord(id: _uuid.v4(), childId: emmaId, date: DateTime(2025, 3, 15), heightCm: 75.5, weightKg: 10.0, headCircumferenceCm: 46.5, notes: '12-month check-up'),
      HealthRecord(id: _uuid.v4(), childId: emmaId, date: DateTime(2025, 9, 15), heightCm: 82.0, weightKg: 11.5, headCircumferenceCm: 47.5, notes: '18-month check-up'),
      HealthRecord(id: _uuid.v4(), childId: emmaId, date: DateTime(2026, 3, 15), heightCm: 87.5, weightKg: 12.3, headCircumferenceCm: 48.5, notes: '24-month check-up'),
    ];

    for (final r in emmaHealth) {
      await saveHealthRecord(r);
    }

    // -- Health Records for Noah --
    final noahHealth = [
      HealthRecord(id: _uuid.v4(), childId: noahId, date: DateTime(2025, 10, 1), heightCm: 50.0, weightKg: 3.4, headCircumferenceCm: 34.5, notes: 'Birth measurements'),
      HealthRecord(id: _uuid.v4(), childId: noahId, date: DateTime(2026, 1, 1), heightCm: 62.5, weightKg: 6.8, headCircumferenceCm: 41.0, notes: '3-month check-up'),
      HealthRecord(id: _uuid.v4(), childId: noahId, date: DateTime(2026, 3, 20), heightCm: 65.0, weightKg: 7.5, headCircumferenceCm: 42.0, notes: '5-month check-up'),
    ];

    for (final r in noahHealth) {
      await saveHealthRecord(r);
    }

    // -- Mood Entries for Emma (last 7 days) --
    final moodActivities = [
      ['outdoor play', 'reading'],
      ['social play', 'music'],
      ['outdoor play'],
      ['reading', 'arts & crafts'],
      ['music', 'dancing'],
      ['social play'],
      ['outdoor play', 'reading', 'music'],
    ];
    final moodLevels = [MoodLevel.good, MoodLevel.great, MoodLevel.okay, MoodLevel.good, MoodLevel.great, MoodLevel.sad, MoodLevel.good];
    final moodNotes = [
      'Had a great time at the park',
      'Playdate with cousin Leo — laughed non-stop',
      'A bit fussy after nap but settled down',
      'Quiet day at home, enjoyed storytime',
      'Dance party in the living room!',
      'Teething pain — not her best day',
      'Wonderful day overall',
    ];

    for (int i = 0; i < 7; i++) {
      final entry = MoodEntry(
        id: _uuid.v4(),
        childId: emmaId,
        date: now.subtract(Duration(days: 6 - i)),
        mood: moodLevels[i],
        notes: moodNotes[i],
        activities: moodActivities[i],
      );
      await saveMoodEntry(entry);
    }

    // -- Reminders --
    final reminders = [
      ReminderModel(
        id: _uuid.v4(),
        childId: noahId,
        title: 'MMR Vaccine',
        description: 'Noah\'s MMR (Measles, Mumps, Rubella) vaccination at the pediatrician.',
        dateTime: now.add(const Duration(days: 5)),
        type: ReminderType.vaccination,
      ),
      ReminderModel(
        id: _uuid.v4(),
        childId: emmaId,
        title: 'Annual Check-up',
        description: 'Emma\'s 2-year annual health and development check-up.',
        dateTime: now.add(const Duration(days: 12)),
        type: ReminderType.checkup,
      ),
      ReminderModel(
        id: _uuid.v4(),
        childId: emmaId,
        title: 'Dentist Appointment',
        description: 'First dentist visit — routine oral health check.',
        dateTime: now.add(const Duration(days: 28)),
        type: ReminderType.other,
      ),
      ReminderModel(
        id: _uuid.v4(),
        childId: noahId,
        title: 'Hepatitis B Booster',
        description: 'Noah\'s Hepatitis B third dose booster.',
        dateTime: now.add(const Duration(days: 45)),
        type: ReminderType.vaccination,
      ),
    ];

    for (final r in reminders) {
      await saveReminder(r);
    }

    await prefs.setBool(_seededKey, true);
  }
}
