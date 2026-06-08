import 'package:hive/hive.dart';

part 'alarm_models.g.dart';

/// A single yes/no personalization question that adds prep time when enabled.
///
/// e.g. "Are you doing makeup?" -> +25 min.
@HiveType(typeId: 0)
class AlarmQuestion extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  int addedMinutes;

  /// User-created questions vs. the built-in seed set.
  @HiveField(3)
  bool isCustom;

  AlarmQuestion({
    required this.id,
    required this.label,
    required this.addedMinutes,
    this.isCustom = false,
  });

  AlarmQuestion copyWith({String? label, int? addedMinutes, bool? isCustom}) {
    return AlarmQuestion(
      id: id,
      label: label ?? this.label,
      addedMinutes: addedMinutes ?? this.addedMinutes,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

/// A reusable alarm configuration (e.g. "Going to work") that doesn't change
/// much. Stores the leave/ready time as minutes-since-midnight plus which
/// questions apply.
@HiveType(typeId: 1)
class AlarmPreset extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  /// The time the user needs to leave / be ready, as minutes since midnight.
  @HiveField(2)
  int anchorMinutesSinceMidnight;

  /// Ids of [AlarmQuestion]s that are enabled for this preset.
  @HiveField(3)
  List<String> enabledQuestionIds;

  @HiveField(4)
  int baseBufferMinutes;

  @HiveField(5)
  int snoozeWindowMinutes;

  @HiveField(6)
  int snoozeIntervalMinutes;

  AlarmPreset({
    required this.id,
    required this.name,
    required this.anchorMinutesSinceMidnight,
    required this.enabledQuestionIds,
    required this.baseBufferMinutes,
    required this.snoozeWindowMinutes,
    required this.snoozeIntervalMinutes,
  });

  AlarmPreset copyWith({
    String? name,
    int? anchorMinutesSinceMidnight,
    List<String>? enabledQuestionIds,
    int? baseBufferMinutes,
    int? snoozeWindowMinutes,
    int? snoozeIntervalMinutes,
  }) {
    return AlarmPreset(
      id: id,
      name: name ?? this.name,
      anchorMinutesSinceMidnight:
          anchorMinutesSinceMidnight ?? this.anchorMinutesSinceMidnight,
      enabledQuestionIds: enabledQuestionIds ?? this.enabledQuestionIds,
      baseBufferMinutes: baseBufferMinutes ?? this.baseBufferMinutes,
      snoozeWindowMinutes: snoozeWindowMinutes ?? this.snoozeWindowMinutes,
      snoozeIntervalMinutes:
          snoozeIntervalMinutes ?? this.snoozeIntervalMinutes,
    );
  }
}

/// Lifecycle state of a concrete scheduled alarm.
@HiveType(typeId: 2)
enum AlarmRunState {
  @HiveField(0)
  scheduled,
  @HiveField(1)
  ringing,
  @HiveField(2)
  snoozed,
  /// Snooze budget exhausted — vibrate-only, QR scan required to dismiss.
  @HiveField(3)
  escalated,
  @HiveField(4)
  dismissed,
}

/// A concrete alarm pinned to a specific morning, with resolved times and the
/// live snooze state machine.
@HiveType(typeId: 3)
class ScheduledAlarm extends HiveObject {
  @HiveField(0)
  final String id;

  /// When the user needs to leave / be ready.
  @HiveField(1)
  DateTime anchorTime;

  /// When the user should physically be out of bed.
  @HiveField(2)
  DateTime outOfBedTime;

  /// When the alarm first rings (out-of-bed minus snooze window).
  @HiveField(3)
  DateTime firstRingTime;

  @HiveField(4)
  int snoozeIntervalMinutes;

  @HiveField(5)
  int maxSnoozes;

  @HiveField(6)
  int snoozeCount;

  @HiveField(7)
  AlarmRunState state;

  /// Expected QR payload required to dismiss once escalated.
  @HiveField(8)
  String escalationQrPayload;

  /// Total prep minutes (base + activities) used to compute this alarm.
  @HiveField(9)
  int prepMinutes;

  /// Optional link back to the preset this was generated from.
  @HiveField(10)
  String? presetId;

  ScheduledAlarm({
    required this.id,
    required this.anchorTime,
    required this.outOfBedTime,
    required this.firstRingTime,
    required this.snoozeIntervalMinutes,
    required this.maxSnoozes,
    required this.escalationQrPayload,
    required this.prepMinutes,
    this.snoozeCount = 0,
    this.state = AlarmRunState.scheduled,
    this.presetId,
  });

  /// Whether any further snoozes are allowed before escalation.
  bool get canSnooze => snoozeCount < maxSnoozes;

  /// The next time the alarm should ring given the current snooze count.
  DateTime get nextRingTime =>
      firstRingTime.add(Duration(minutes: snoozeIntervalMinutes * snoozeCount));
}
