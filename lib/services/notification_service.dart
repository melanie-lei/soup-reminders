import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around [FlutterLocalNotificationsPlugin] plus timezone setup.
///
/// Handles two kinds of notifications:
///  * **Alarms** — high-importance, full-screen-intent, custom sound. Used by
///    the alarm scheduler for ring / escalation events.
///  * **Task reminders** — standard reminders nudging the user to start a task.
///
/// NOTE (UI/native follow-up): a truly reliable alarm that fires when the app
/// is killed needs a full-screen-intent + exact-alarm permission on Android 13+
/// (`SCHEDULE_EXACT_ALARM` / `USE_FULL_SCREEN_INTENT`) and an iOS critical-alert
/// entitlement. The scheduling logic lives here; the permission wiring + native
/// channels are flagged as TODO and should be finished alongside the UI.
class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const String alarmChannelId = 'alarm_channel';
  static const String alarmEscalationChannelId = 'alarm_escalation_channel';
  static const String taskChannelId = 'task_reminder_channel';

  bool _initialized = false;

  /// Initialize timezone data and platform notification settings.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _createAndroidChannels();
    _initialized = true;
  }

  Future<void> _createAndroidChannels() async {
    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        alarmChannelId,
        'Alarms',
        description: 'Wake-up alarms',
        importance: Importance.max,
        playSound: true,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        alarmEscalationChannelId,
        'Alarm escalation',
        description: 'Vibrate-only escalation after snooze runs out',
        importance: Importance.max,
        playSound: false,
        enableVibration: true,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        taskChannelId,
        'Task reminders',
        description: 'Nudges to start your next task',
        importance: Importance.high,
      ),
    );
  }

  /// Request OS-level notification + exact-alarm permissions.
  /// Returns true if (best-effort) granted.
  Future<bool> requestPermissions() async {
    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final ios =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    bool granted = true;
    if (android != null) {
      granted = (await android.requestNotificationsPermission()) ?? granted;
      await android.requestExactAlarmsPermission();
    }
    if (ios != null) {
      granted = (await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          )) ??
          granted;
    }
    return granted;
  }

  /// Schedule a one-shot alarm notification at [when].
  Future<void> scheduleAlarm({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    bool escalation = false,
    String? payload,
  }) async {
    final channel = escalation ? alarmEscalationChannelId : alarmChannelId;
    final androidDetails = AndroidNotificationDetails(
      channel,
      escalation ? 'Alarm escalation' : 'Alarms',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: !escalation,
      enableVibration: true,
      ongoing: true,
      autoCancel: false,
    );

    await _zonedSchedule(
      id: id,
      when: when,
      title: title,
      body: body,
      payload: payload,
      details: NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.critical,
          presentSound: !escalation,
        ),
      ),
    );
  }

  /// Schedule a task reminder notification at [when].
  Future<void> scheduleTaskReminder({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _zonedSchedule(
      id: id,
      when: when,
      title: title,
      body: body,
      payload: payload,
      details: const NotificationDetails(
        android: AndroidNotificationDetails(
          taskChannelId,
          'Task reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> _zonedSchedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    required NotificationDetails details,
    String? payload,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
