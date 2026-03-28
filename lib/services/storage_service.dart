import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/child_model.dart';
import '../models/milestone_model.dart';
import '../models/health_record_model.dart';
import '../models/mood_entry_model.dart';
import '../models/reminder_model.dart';

class StorageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const _uuid = Uuid();

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _col(String name) {
    final uid = _userId;
    if (uid != null) {
      return _db.collection('users').doc(uid).collection(name);
    }
    return _db.collection('anonymous').doc('guest').collection(name);
  }

  // ── Children ────────────────────────────────────────────────────

  Future<List<ChildModel>> getChildren() async {
    final snap = await _col('children').get();
    return snap.docs.map((d) => ChildModel.fromJson(d.data())).toList();
  }

  Future<void> saveChild(ChildModel child) async {
    await _col('children').doc(child.id).set(child.toJson());
  }

  Future<void> deleteChild(String childId) async {
    await _col('children').doc(childId).delete();
    await deleteMilestonesForChild(childId);
    await deleteHealthRecordsForChild(childId);
    await deleteMoodEntriesForChild(childId);
    await deleteRemindersForChild(childId);
  }

  // ── Milestones ──────────────────────────────────────────────────

  Future<List<MilestoneModel>> getMilestones({String? childId}) async {
    Query<Map<String, dynamic>> q = _col('milestones');
    if (childId != null) q = q.where('childId', isEqualTo: childId);
    final snap = await q.get();
    return snap.docs.map((d) => MilestoneModel.fromJson(d.data())).toList();
  }

  Future<void> saveMilestone(MilestoneModel milestone) async {
    await _col('milestones').doc(milestone.id).set(milestone.toJson());
  }

  Future<void> deleteMilestone(String milestoneId) async {
    await _col('milestones').doc(milestoneId).delete();
  }

  Future<void> deleteMilestonesForChild(String childId) async {
    final snap =
        await _col('milestones').where('childId', isEqualTo: childId).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ── Health Records ──────────────────────────────────────────────

  Future<List<HealthRecord>> getHealthRecords({String? childId}) async {
    Query<Map<String, dynamic>> q = _col('health_records');
    if (childId != null) q = q.where('childId', isEqualTo: childId);
    final snap = await q.get();
    return snap.docs.map((d) => HealthRecord.fromJson(d.data())).toList();
  }

  Future<void> saveHealthRecord(HealthRecord record) async {
    await _col('health_records').doc(record.id).set(record.toJson());
  }

  Future<void> deleteHealthRecord(String recordId) async {
    await _col('health_records').doc(recordId).delete();
  }

  Future<void> deleteHealthRecordsForChild(String childId) async {
    final snap = await _col('health_records')
        .where('childId', isEqualTo: childId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ── Mood Entries ────────────────────────────────────────────────

  Future<List<MoodEntry>> getMoodEntries({String? childId}) async {
    Query<Map<String, dynamic>> q = _col('mood_entries');
    if (childId != null) q = q.where('childId', isEqualTo: childId);
    final snap = await q.get();
    return snap.docs.map((d) => MoodEntry.fromJson(d.data())).toList();
  }

  Future<void> saveMoodEntry(MoodEntry entry) async {
    await _col('mood_entries').doc(entry.id).set(entry.toJson());
  }

  Future<void> deleteMoodEntry(String entryId) async {
    await _col('mood_entries').doc(entryId).delete();
  }

  Future<void> deleteMoodEntriesForChild(String childId) async {
    final snap =
        await _col('mood_entries').where('childId', isEqualTo: childId).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ── Reminders ───────────────────────────────────────────────────

  Future<List<ReminderModel>> getReminders({String? childId}) async {
    Query<Map<String, dynamic>> q = _col('reminders');
    if (childId != null) q = q.where('childId', isEqualTo: childId);
    final snap = await q.get();
    return snap.docs.map((d) => ReminderModel.fromJson(d.data())).toList();
  }

  Future<void> saveReminder(ReminderModel reminder) async {
    await _col('reminders').doc(reminder.id).set(reminder.toJson());
  }

  Future<void> deleteReminder(String reminderId) async {
    await _col('reminders').doc(reminderId).delete();
  }

  Future<void> deleteRemindersForChild(String childId) async {
    final snap =
        await _col('reminders').where('childId', isEqualTo: childId).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ── Seed ────────────────────────────────────────────────────────

  Future<bool> isSeeded() async {
    final uid = _userId;
    if (uid == null) return false;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['seeded'] == true;
  }

  Future<void> seedSampleData() async {
    if (await isSeeded()) return;
    final now = DateTime.now();
    const emmaId = 'child_emma_001';
    const noahId = 'child_noah_001';

    await saveChild(ChildModel(
      id: emmaId,
      name: 'Emma',
      birthDate: DateTime(2024, 3, 15),
      gender: 'female',
      notes: 'Loves music and dancing. Favourite toy is her stuffed bunny.',
    ));
    await saveChild(ChildModel(
      id: noahId,
      name: 'Noah',
      birthDate: DateTime(2025, 10, 1),
      gender: 'male',
      notes: 'Very alert and curious. Loves tummy time.',
    ));

    for (final m in [
      MilestoneModel(id: _uuid.v4(), childId: emmaId, title: 'First Word "Mama"', description: 'Emma said her first word!', date: DateTime(2024, 9, 5), category: MilestoneCategory.language),
      MilestoneModel(id: _uuid.v4(), childId: emmaId, title: 'Started Walking', description: 'Emma took her first independent steps — 5 steps in a row!', date: DateTime(2025, 1, 20), category: MilestoneCategory.motor),
      MilestoneModel(id: _uuid.v4(), childId: emmaId, title: 'Ate Solid Food', description: 'First taste of pureed sweet potato.', date: DateTime(2024, 9, 15), category: MilestoneCategory.other),
      MilestoneModel(id: _uuid.v4(), childId: emmaId, title: 'Recognised Colours', description: 'Correctly identified red, blue, and yellow.', date: DateTime(2025, 11, 10), category: MilestoneCategory.cognitive),
      MilestoneModel(id: _uuid.v4(), childId: noahId, title: 'First Smile', description: 'Noah gave us his very first real social smile!', date: DateTime(2025, 11, 1), category: MilestoneCategory.social),
      MilestoneModel(id: _uuid.v4(), childId: noahId, title: 'Started Rolling Over', description: 'Rolled from tummy to back during tummy time.', date: DateTime(2026, 1, 14), category: MilestoneCategory.motor),
    ]) {
      await saveMilestone(m);
    }

    for (final r in [
      HealthRecord(id: _uuid.v4(), childId: emmaId, date: DateTime(2024, 3, 15), heightCm: 49.5, weightKg: 3.2, headCircumferenceCm: 34.0, notes: 'Birth measurements'),
      HealthRecord(id: _uuid.v4(), childId: emmaId, date: DateTime(2024, 9, 15), heightCm: 67.5, weightKg: 8.1, headCircumferenceCm: 43.0, notes: '6-month check-up'),
      HealthRecord(id: _uuid.v4(), childId: emmaId, date: DateTime(2026, 3, 15), heightCm: 87.5, weightKg: 12.3, headCircumferenceCm: 48.5, notes: '24-month check-up'),
      HealthRecord(id: _uuid.v4(), childId: noahId, date: DateTime(2025, 10, 1), heightCm: 50.0, weightKg: 3.4, headCircumferenceCm: 34.5, notes: 'Birth measurements'),
      HealthRecord(id: _uuid.v4(), childId: noahId, date: DateTime(2026, 1, 1), heightCm: 62.5, weightKg: 6.8, headCircumferenceCm: 41.0, notes: '3-month check-up'),
    ]) {
      await saveHealthRecord(r);
    }

    final moodLevels = [MoodLevel.good, MoodLevel.great, MoodLevel.okay, MoodLevel.good, MoodLevel.great, MoodLevel.sad, MoodLevel.good];
    final moodActivities = [['outdoor play', 'reading'], ['social play', 'music'], ['outdoor play'], ['reading', 'arts & crafts'], ['music', 'dancing'], ['social play'], ['outdoor play', 'reading', 'music']];
    final moodNotes = ['Had a great time at the park', 'Playdate with cousin Leo', 'A bit fussy after nap', 'Quiet day at home', 'Dance party!', 'Teething pain', 'Wonderful day'];
    for (int i = 0; i < 7; i++) {
      await saveMoodEntry(MoodEntry(
        id: _uuid.v4(),
        childId: emmaId,
        date: now.subtract(Duration(days: 6 - i)),
        mood: moodLevels[i],
        notes: moodNotes[i],
        activities: moodActivities[i],
      ));
    }

    for (final r in [
      ReminderModel(id: _uuid.v4(), childId: noahId, title: 'MMR Vaccine', description: "Noah's MMR vaccination at the pediatrician.", dateTime: now.add(const Duration(days: 5)), type: ReminderType.vaccination),
      ReminderModel(id: _uuid.v4(), childId: emmaId, title: 'Annual Check-up', description: "Emma's 2-year annual check-up.", dateTime: now.add(const Duration(days: 12)), type: ReminderType.checkup),
      ReminderModel(id: _uuid.v4(), childId: emmaId, title: 'Dentist Appointment', description: 'First dentist visit — routine oral health check.', dateTime: now.add(const Duration(days: 28)), type: ReminderType.other),
    ]) {
      await saveReminder(r);
    }

    final uid = _userId;
    if (uid != null) {
      await _db
          .collection('users')
          .doc(uid)
          .set({'seeded': true}, SetOptions(merge: true));
    }
  }
}
