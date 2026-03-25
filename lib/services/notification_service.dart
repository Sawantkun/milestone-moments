import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    _initialized = true;
  }

  NotificationDetails _buildDetails(ReminderType type) {
    final String channelId;
    final String channelName;
    final String channelDesc;

    switch (type) {
      case ReminderType.vaccination:
        channelId = 'vaccination_channel';
        channelName = 'Vaccinations';
        channelDesc = 'Vaccination reminders for your children';
        break;
      case ReminderType.checkup:
        channelId = 'checkup_channel';
        channelName = 'Health Check-ups';
        channelDesc = 'Doctor appointment reminders';
        break;
      case ReminderType.other:
        channelId = 'general_channel';
        channelName = 'General Reminders';
        channelDesc = 'General parenting reminders';
        break;
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: const DefaultStyleInformation(true, true),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Schedule a local notification for the given [reminder].
  Future<void> scheduleReminder(ReminderModel reminder) async {
    await initialize();

    final scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isBefore(now)) return;

    final notifId = reminder.id.hashCode.abs() % 100000;

    try {
      await _plugin.zonedSchedule(
        notifId,
        reminder.title,
        reminder.description,
        scheduledDate,
        _buildDetails(reminder.type),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.id,
      );
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  /// Cancel the notification for the given reminder id.
  Future<void> cancelReminder(String reminderId) async {
    await initialize();
    final notifId = reminderId.hashCode.abs() % 100000;
    await _plugin.cancel(notifId);
  }

  /// Show an immediate notification.
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'immediate_channel',
      'Immediate Notifications',
      channelDescription: 'Immediate alerts from MilestoneMoments',
      importance: Importance.max,
      priority: Priority.max,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
