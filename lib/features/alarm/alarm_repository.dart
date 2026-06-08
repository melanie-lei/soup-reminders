import 'package:hive/hive.dart';
import 'package:soup_reminders/core/constants.dart';
import 'package:soup_reminders/features/alarm/models/alarm_models.dart';

/// Hive-backed persistence for the alarm domain: the question library, presets,
/// and concrete scheduled alarms.
class AlarmRepository {
  AlarmRepository({
    required Box<AlarmQuestion> questions,
    required Box<AlarmPreset> presets,
    required Box<ScheduledAlarm> scheduled,
  })  : _questions = questions,
        _presets = presets,
        _scheduled = scheduled;

  final Box<AlarmQuestion> _questions;
  final Box<AlarmPreset> _presets;
  final Box<ScheduledAlarm> _scheduled;

  /// Seed the built-in questions on first run.
  Future<void> seedDefaults() async {
    if (_questions.isNotEmpty) return;
    for (final q in DefaultAlarmQuestions.seed) {
      await _questions.put(
        q.id,
        AlarmQuestion(id: q.id, label: q.label, addedMinutes: q.minutes),
      );
    }
  }

  // ---- Questions ----
  List<AlarmQuestion> get questions => _questions.values.toList();

  Future<void> upsertQuestion(AlarmQuestion question) =>
      _questions.put(question.id, question);

  Future<void> deleteQuestion(String id) => _questions.delete(id);

  // ---- Presets ----
  List<AlarmPreset> get presets => _presets.values.toList();

  AlarmPreset? preset(String id) => _presets.get(id);

  Future<void> upsertPreset(AlarmPreset preset) =>
      _presets.put(preset.id, preset);

  Future<void> deletePreset(String id) => _presets.delete(id);

  // ---- Scheduled alarms ----
  List<ScheduledAlarm> get scheduledAlarms => _scheduled.values.toList();

  ScheduledAlarm? scheduledAlarm(String id) => _scheduled.get(id);

  /// The next upcoming, non-dismissed alarm by ring time, if any.
  ScheduledAlarm? get nextAlarm {
    final active = _scheduled.values
        .where((a) => a.state != AlarmRunState.dismissed)
        .toList()
      ..sort((a, b) => a.firstRingTime.compareTo(b.firstRingTime));
    return active.isEmpty ? null : active.first;
  }

  Future<void> saveScheduled(ScheduledAlarm alarm) =>
      _scheduled.put(alarm.id, alarm);

  Future<void> deleteScheduled(String id) => _scheduled.delete(id);
}
