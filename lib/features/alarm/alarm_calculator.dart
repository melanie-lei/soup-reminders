import 'package:soup_reminders/core/constants.dart';
import 'package:soup_reminders/features/alarm/models/alarm_models.dart';

/// Result of resolving an alarm from an anchor time + enabled questions.
class AlarmComputation {
  /// When the user needs to leave / be ready (the input anchor).
  final DateTime anchorTime;

  /// When the user should physically be out of bed.
  final DateTime outOfBedTime;

  /// When the alarm first rings.
  final DateTime firstRingTime;

  /// base buffer + sum of enabled question minutes.
  final int prepMinutes;

  /// Minutes of snooze allowed before escalation.
  final int snoozeWindowMinutes;

  const AlarmComputation({
    required this.anchorTime,
    required this.outOfBedTime,
    required this.firstRingTime,
    required this.prepMinutes,
    required this.snoozeWindowMinutes,
  });
}

/// Pure alarm-time math. No I/O, fully unit-testable.
///
/// Model (validated against the product spec example):
///   outOfBedTime  = anchorTime − baseBuffer − Σ(enabled question minutes)
///   firstRingTime = outOfBedTime − snoozeWindow
///
/// Example: leave 09:30, makeup (+25), base 30, snooze 20
///   prep        = 30 + 25 = 55
///   outOfBed    = 09:30 − 55 = 08:35
///   firstRing   = 08:35 − 20 = 08:15
class AlarmCalculator {
  const AlarmCalculator();

  /// Sum the added minutes of the [enabledIds] against the [questionLibrary].
  int activityMinutes({
    required Iterable<String> enabledIds,
    required Iterable<AlarmQuestion> questionLibrary,
  }) {
    final byId = {for (final q in questionLibrary) q.id: q};
    var total = 0;
    for (final id in enabledIds) {
      final q = byId[id];
      if (q != null) total += q.addedMinutes;
    }
    return total;
  }

  /// Compute alarm times from an explicit anchor [DateTime].
  AlarmComputation compute({
    required DateTime anchorTime,
    int activityMinutes = 0,
    int baseBufferMinutes = AppDefaults.baseBufferMinutes,
    int snoozeWindowMinutes = AppDefaults.snoozeWindowMinutes,
  }) {
    final prep = baseBufferMinutes + activityMinutes;
    final outOfBed = anchorTime.subtract(Duration(minutes: prep));
    final firstRing = outOfBed.subtract(Duration(minutes: snoozeWindowMinutes));
    return AlarmComputation(
      anchorTime: anchorTime,
      outOfBedTime: outOfBed,
      firstRingTime: firstRing,
      prepMinutes: prep,
      snoozeWindowMinutes: snoozeWindowMinutes,
    );
  }

  /// Resolve an [AlarmPreset] into a concrete [ScheduledAlarm] for [date].
  ///
  /// [date] is the calendar day the alarm's *anchor time* falls on. Generates
  /// a fresh id + QR payload via the provided callbacks.
  ScheduledAlarm scheduledFromPreset({
    required AlarmPreset preset,
    required DateTime date,
    required Iterable<AlarmQuestion> questionLibrary,
    required String id,
    required String qrPayload,
  }) {
    final anchor = _atTime(date, preset.anchorMinutesSinceMidnight);
    final activity = activityMinutes(
      enabledIds: preset.enabledQuestionIds,
      questionLibrary: questionLibrary,
    );
    final comp = compute(
      anchorTime: anchor,
      activityMinutes: activity,
      baseBufferMinutes: preset.baseBufferMinutes,
      snoozeWindowMinutes: preset.snoozeWindowMinutes,
    );
    final maxSnoozes = preset.snoozeIntervalMinutes <= 0
        ? 0
        : preset.snoozeWindowMinutes ~/ preset.snoozeIntervalMinutes;
    return ScheduledAlarm(
      id: id,
      anchorTime: comp.anchorTime,
      outOfBedTime: comp.outOfBedTime,
      firstRingTime: comp.firstRingTime,
      snoozeIntervalMinutes: preset.snoozeIntervalMinutes,
      maxSnoozes: maxSnoozes,
      escalationQrPayload: qrPayload,
      prepMinutes: comp.prepMinutes,
      presetId: preset.id,
    );
  }

  /// Build a one-off [ScheduledAlarm] without a preset.
  ScheduledAlarm scheduledOneOff({
    required DateTime anchorTime,
    required Iterable<String> enabledQuestionIds,
    required Iterable<AlarmQuestion> questionLibrary,
    required String id,
    required String qrPayload,
    int baseBufferMinutes = AppDefaults.baseBufferMinutes,
    int snoozeWindowMinutes = AppDefaults.snoozeWindowMinutes,
    int snoozeIntervalMinutes = AppDefaults.snoozeIntervalMinutes,
  }) {
    final activity = activityMinutes(
      enabledIds: enabledQuestionIds,
      questionLibrary: questionLibrary,
    );
    final comp = compute(
      anchorTime: anchorTime,
      activityMinutes: activity,
      baseBufferMinutes: baseBufferMinutes,
      snoozeWindowMinutes: snoozeWindowMinutes,
    );
    final maxSnoozes =
        snoozeIntervalMinutes <= 0 ? 0 : snoozeWindowMinutes ~/ snoozeIntervalMinutes;
    return ScheduledAlarm(
      id: id,
      anchorTime: comp.anchorTime,
      outOfBedTime: comp.outOfBedTime,
      firstRingTime: comp.firstRingTime,
      snoozeIntervalMinutes: snoozeIntervalMinutes,
      maxSnoozes: maxSnoozes,
      escalationQrPayload: qrPayload,
      prepMinutes: comp.prepMinutes,
    );
  }

  DateTime _atTime(DateTime date, int minutesSinceMidnight) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      minutesSinceMidnight ~/ 60,
      minutesSinceMidnight % 60,
    );
  }
}
