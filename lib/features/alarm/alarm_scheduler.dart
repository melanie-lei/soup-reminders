import 'package:soup_reminders/features/alarm/models/alarm_models.dart';
import 'package:soup_reminders/services/notification_service.dart';

/// Outcome of attempting to dismiss an alarm.
enum DismissResult {
  /// Alarm dismissed successfully.
  dismissed,

  /// Alarm is escalated and requires a QR scan; the supplied payload was wrong
  /// or missing.
  qrRequired,
}

/// Drives the alarm's snooze state machine and (re)schedules notifications.
///
/// Stateless w.r.t. storage — callers persist the mutated [ScheduledAlarm]
/// afterwards (the repository/provider does this).
class AlarmScheduler {
  AlarmScheduler(this._notifications);

  final NotificationService _notifications;

  /// Stable notification id derived from the alarm id (kept small & positive).
  int notificationId(ScheduledAlarm alarm) =>
      alarm.id.hashCode & 0x7fffffff;

  /// Schedule the initial ring for [alarm].
  Future<void> schedule(ScheduledAlarm alarm) async {
    alarm.state = AlarmRunState.scheduled;
    await _notifications.scheduleAlarm(
      id: notificationId(alarm),
      when: alarm.firstRingTime,
      title: 'Time to get up',
      body: 'Be out of bed by '
          '${_fmt(alarm.outOfBedTime)} — you have '
          '${alarm.maxSnoozes * alarm.snoozeIntervalMinutes} min of snooze.',
      payload: 'alarm:${alarm.id}',
    );
  }

  /// Advance the snooze state machine by one interval.
  ///
  /// Returns the mutated [alarm]. When the snooze budget is exhausted the alarm
  /// transitions to [AlarmRunState.escalated] and the next ring is vibrate-only
  /// + QR-locked.
  Future<ScheduledAlarm> snooze(ScheduledAlarm alarm) async {
    await _notifications.cancel(notificationId(alarm));

    if (alarm.canSnooze) {
      alarm.snoozeCount += 1;
      final escalating = !alarm.canSnooze; // just used the last snooze
      alarm.state =
          escalating ? AlarmRunState.escalated : AlarmRunState.snoozed;

      await _notifications.scheduleAlarm(
        id: notificationId(alarm),
        when: alarm.nextRingTime,
        title: escalating ? 'Snooze is over — get up!' : 'Still snoozing…',
        body: escalating
            ? 'Scan your QR code to turn this off.'
            : 'Be out of bed by ${_fmt(alarm.outOfBedTime)}.',
        escalation: escalating,
        payload: 'alarm:${alarm.id}',
      );
    } else {
      // Already past the budget — re-arm the escalation ring.
      alarm.state = AlarmRunState.escalated;
      await _notifications.scheduleAlarm(
        id: notificationId(alarm),
        when: alarm.nextRingTime
            .add(Duration(minutes: alarm.snoozeIntervalMinutes)),
        title: 'Get up!',
        body: 'Scan your QR code to turn this off.',
        escalation: true,
        payload: 'alarm:${alarm.id}',
      );
    }
    return alarm;
  }

  /// Attempt to dismiss [alarm].
  ///
  /// When escalated, [scannedQrPayload] must match the alarm's expected payload.
  Future<DismissResult> dismiss(
    ScheduledAlarm alarm, {
    String? scannedQrPayload,
  }) async {
    if (alarm.state == AlarmRunState.escalated) {
      if (scannedQrPayload == null ||
          scannedQrPayload != alarm.escalationQrPayload) {
        return DismissResult.qrRequired;
      }
    }
    await _notifications.cancel(notificationId(alarm));
    alarm.state = AlarmRunState.dismissed;
    return DismissResult.dismissed;
  }

  /// Cancel a scheduled alarm without marking it dismissed (e.g. user deletes).
  Future<void> cancel(ScheduledAlarm alarm) =>
      _notifications.cancel(notificationId(alarm));

  String _fmt(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
