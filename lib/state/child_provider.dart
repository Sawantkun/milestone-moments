import 'package:flutter/foundation.dart';
import '../models/child_model.dart';
import '../models/milestone_model.dart';
import '../models/health_record_model.dart';
import '../models/mood_entry_model.dart';
import '../models/reminder_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class ChildProvider extends ChangeNotifier {
  final StorageService _storage;
  final NotificationService _notifications;

  List<ChildModel> _children = [];
  ChildModel? _selectedChild;
  List<MilestoneModel> _milestones = [];
  List<HealthRecord> _healthRecords = [];
  List<MoodEntry> _moodEntries = [];
  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _error;

  ChildProvider(this._storage, this._notifications);

  List<ChildModel> get children => List.unmodifiable(_children);
  ChildModel? get selectedChild => _selectedChild;
  List<MilestoneModel> get milestones => List.unmodifiable(_milestones);
  List<HealthRecord> get healthRecords => List.unmodifiable(_healthRecords);
  List<MoodEntry> get moodEntries => List.unmodifiable(_moodEntries);
  List<ReminderModel> get reminders => List.unmodifiable(_reminders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<MilestoneModel> milestonesForChild(String childId) =>
      _milestones.where((m) => m.childId == childId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<HealthRecord> healthRecordsForChild(String childId) =>
      _healthRecords.where((r) => r.childId == childId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<MoodEntry> moodEntriesForChild(String childId) =>
      _moodEntries.where((m) => m.childId == childId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<ReminderModel> remindersForChild(String childId) =>
      _reminders.where((r) => r.childId == childId).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<ReminderModel> get upcomingReminders {
    final now = DateTime.now();
    return _reminders
        .where((r) => !r.isCompleted && r.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> loadAll() async {
    _setLoading(true);
    try {
      _children = await _storage.getChildren();
      _milestones = await _storage.getMilestones();
      _healthRecords = await _storage.getHealthRecords();
      _moodEntries = await _storage.getMoodEntries();
      _reminders = await _storage.getReminders();

      if (_selectedChild == null && _children.isNotEmpty) {
        _selectedChild = _children.first;
      } else if (_selectedChild != null) {
        // Refresh selected child data in case it was updated
        final idx = _children.indexWhere((c) => c.id == _selectedChild!.id);
        if (idx >= 0) {
          _selectedChild = _children[idx];
        } else if (_children.isNotEmpty) {
          _selectedChild = _children.first;
        } else {
          _selectedChild = null;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void selectChild(String childId) {
    final child = _children.firstWhere(
      (c) => c.id == childId,
      orElse: () => _children.first,
    );
    _selectedChild = child;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Children CRUD
  // ---------------------------------------------------------------------------

  Future<void> addChild(ChildModel child) async {
    await _storage.saveChild(child);
    _children.add(child);
    _selectedChild ??= child;
    notifyListeners();
  }

  Future<void> updateChild(ChildModel child) async {
    await _storage.saveChild(child);
    final idx = _children.indexWhere((c) => c.id == child.id);
    if (idx >= 0) _children[idx] = child;
    if (_selectedChild?.id == child.id) _selectedChild = child;
    notifyListeners();
  }

  Future<void> deleteChild(String childId) async {
    await _storage.deleteChild(childId);
    _children.removeWhere((c) => c.id == childId);
    _milestones.removeWhere((m) => m.childId == childId);
    _healthRecords.removeWhere((r) => r.childId == childId);
    _moodEntries.removeWhere((m) => m.childId == childId);
    _reminders.removeWhere((r) => r.childId == childId);

    if (_selectedChild?.id == childId) {
      _selectedChild = _children.isNotEmpty ? _children.first : null;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Milestones CRUD
  // ---------------------------------------------------------------------------

  Future<void> addMilestone(MilestoneModel milestone) async {
    await _storage.saveMilestone(milestone);
    _milestones.add(milestone);
    notifyListeners();
  }

  Future<void> updateMilestone(MilestoneModel milestone) async {
    await _storage.saveMilestone(milestone);
    final idx = _milestones.indexWhere((m) => m.id == milestone.id);
    if (idx >= 0) _milestones[idx] = milestone;
    notifyListeners();
  }

  Future<void> deleteMilestone(String id) async {
    await _storage.deleteMilestone(id);
    _milestones.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Health Records CRUD
  // ---------------------------------------------------------------------------

  Future<void> addHealthRecord(HealthRecord record) async {
    await _storage.saveHealthRecord(record);
    _healthRecords.add(record);
    notifyListeners();
  }

  Future<void> updateHealthRecord(HealthRecord record) async {
    await _storage.saveHealthRecord(record);
    final idx = _healthRecords.indexWhere((r) => r.id == record.id);
    if (idx >= 0) _healthRecords[idx] = record;
    notifyListeners();
  }

  Future<void> deleteHealthRecord(String id) async {
    await _storage.deleteHealthRecord(id);
    _healthRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mood Entries CRUD
  // ---------------------------------------------------------------------------

  Future<void> addMoodEntry(MoodEntry entry) async {
    await _storage.saveMoodEntry(entry);
    _moodEntries.add(entry);
    notifyListeners();
  }

  Future<void> updateMoodEntry(MoodEntry entry) async {
    await _storage.saveMoodEntry(entry);
    final idx = _moodEntries.indexWhere((m) => m.id == entry.id);
    if (idx >= 0) _moodEntries[idx] = entry;
    notifyListeners();
  }

  Future<void> deleteMoodEntry(String id) async {
    await _storage.deleteMoodEntry(id);
    _moodEntries.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Reminders CRUD
  // ---------------------------------------------------------------------------

  Future<void> addReminder(ReminderModel reminder) async {
    await _storage.saveReminder(reminder);
    _reminders.add(reminder);
    await _notifications.scheduleReminder(reminder);
    notifyListeners();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _storage.saveReminder(reminder);
    final idx = _reminders.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) _reminders[idx] = reminder;
    await _notifications.cancelReminder(reminder.id);
    if (!reminder.isCompleted) {
      await _notifications.scheduleReminder(reminder);
    }
    notifyListeners();
  }

  Future<void> toggleReminderComplete(String reminderId) async {
    final idx = _reminders.indexWhere((r) => r.id == reminderId);
    if (idx < 0) return;
    final updated = _reminders[idx].copyWith(
      isCompleted: !_reminders[idx].isCompleted,
    );
    await updateReminder(updated);
  }

  Future<void> deleteReminder(String id) async {
    await _storage.deleteReminder(id);
    await _notifications.cancelReminder(id);
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
