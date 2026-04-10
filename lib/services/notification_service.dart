import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request notification permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap — navigation can be wired here
  }

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'blessy_forge_channel',
    'BlessyForge Reminders',
    channelDescription: 'Study and task reminders for BlessyForge',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const NotificationDetails _notifDetails =
      NotificationDetails(android: _androidDetails);

  // Show immediate notification
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _notifDetails);
  }

  // Schedule a one-time notification
  static Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      _notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Schedule a daily repeating notification
  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel a specific notification
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Predefined motivational notifications ───────────────────────────────────

  static Future<void> scheduleDefaultReminders() async {
    await scheduleDailyReminder(
      id: 101,
      title: 'Morning Study Session 📚',
      body: "Blessy, time to study for GATE! Let's crack it!",
      hour: 7,
      minute: 0,
    );

    await scheduleDailyReminder(
      id: 102,
      title: 'Coding Challenge 💻',
      body: 'Solve 2 coding problems today! You can do it, Blessy!',
      hour: 10,
      minute: 0,
    );

    await scheduleDailyReminder(
      id: 103,
      title: 'Stay Consistent 🔥',
      body: 'Stay consistent and forge your future! Keep going, Blessy!',
      hour: 18,
      minute: 0,
    );

    await scheduleDailyReminder(
      id: 104,
      title: 'Evening Review 🌙',
      body: "Review today's progress and plan for tomorrow. You're doing great!",
      hour: 21,
      minute: 0,
    );
  }

  static Future<void> scheduleTaskReminder({
    required int id,
    required String taskTitle,
    required DateTime reminderTime,
  }) async {
    await scheduleOnce(
      id: id,
      title: 'Task Reminder ⏰',
      body: "Don't forget: $taskTitle",
      scheduledTime: reminderTime,
    );
  }

  static Future<void> scheduleAssignmentAlert({
    required int id,
    required String subject,
    required String title,
    required DateTime deadline,
  }) async {
    final alertTime = deadline.subtract(const Duration(hours: 24));
    if (alertTime.isAfter(DateTime.now())) {
      await scheduleOnce(
        id: id,
        title: '⚠️ Assignment Due Tomorrow!',
        body: '$subject: $title is due tomorrow!',
        scheduledTime: alertTime,
      );
    }
  }
}
