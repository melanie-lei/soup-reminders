import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soup_reminders/features/alarm/alarm_calculator.dart';
import 'package:soup_reminders/features/alarm/alarm_repository.dart';
import 'package:soup_reminders/features/alarm/alarm_scheduler.dart';
import 'package:soup_reminders/features/alarm/models/alarm_models.dart';
import 'package:soup_reminders/services/notification_service.dart';

/// Provides the [NotificationService]. Overridden in `main` with the concrete,
/// initialized instance.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('notificationServiceProvider must be '
      'overridden in ProviderScope'),
);

/// Provides the [AlarmRepository]. Overridden in `main` once Hive boxes open.
final alarmRepositoryProvider = Provider<AlarmRepository>(
  (ref) => throw UnimplementedError('alarmRepositoryProvider must be '
      'overridden in ProviderScope'),
);

final alarmCalculatorProvider =
    Provider<AlarmCalculator>((ref) => const AlarmCalculator());

final alarmSchedulerProvider = Provider<AlarmScheduler>(
  (ref) => AlarmScheduler(ref.watch(notificationServiceProvider)),
);

/// The library of personalization questions.
final alarmQuestionsProvider =
    NotifierProvider<AlarmQuestionsNotifier, List<AlarmQuestion>>(
  AlarmQuestionsNotifier.new,
);

class AlarmQuestionsNotifier extends Notifier<List<AlarmQuestion>> {
  @override
  List<AlarmQuestion> build() => ref.watch(alarmRepositoryProvider).questions;

  AlarmRepository get _repo => ref.read(alarmRepositoryProvider);

  Future<void> addCustom({required String label, required int addedMinutes}) async {
    final q = AlarmQuestion(
      id: 'q_${DateTime.now().microsecondsSinceEpoch}',
      label: label,
      addedMinutes: addedMinutes,
      isCustom: true,
    );
    await _repo.upsertQuestion(q);
    state = _repo.questions;
  }

  Future<void> update(AlarmQuestion question) async {
    await _repo.upsertQuestion(question);
    state = _repo.questions;
  }

  Future<void> remove(String id) async {
    await _repo.deleteQuestion(id);
    state = _repo.questions;
  }
}

/// Saved alarm presets.
final alarmPresetsProvider =
    NotifierProvider<AlarmPresetsNotifier, List<AlarmPreset>>(
  AlarmPresetsNotifier.new,
);

class AlarmPresetsNotifier extends Notifier<List<AlarmPreset>> {
  @override
  List<AlarmPreset> build() => ref.watch(alarmRepositoryProvider).presets;

  AlarmRepository get _repo => ref.read(alarmRepositoryProvider);

  Future<void> save(AlarmPreset preset) async {
    await _repo.upsertPreset(preset);
    state = _repo.presets;
  }

  Future<void> remove(String id) async {
    await _repo.deletePreset(id);
    state = _repo.presets;
  }
}

/// The list of concrete scheduled alarms, with snooze/dismiss actions.
final scheduledAlarmsProvider =
    NotifierProvider<ScheduledAlarmsNotifier, List<ScheduledAlarm>>(
  ScheduledAlarmsNotifier.new,
);

class ScheduledAlarmsNotifier extends Notifier<List<ScheduledAlarm>> {
  @override
  List<ScheduledAlarm> build() =>
      ref.watch(alarmRepositoryProvider).scheduledAlarms;

  AlarmRepository get _repo => ref.read(alarmRepositoryProvider);
  AlarmScheduler get _scheduler => ref.read(alarmSchedulerProvider);
  AlarmCalculator get _calc => ref.read(alarmCalculatorProvider);

  ScheduledAlarm? get nextAlarm => _repo.nextAlarm;

  /// Create + schedule an alarm from a preset for [date].
  Future<ScheduledAlarm> scheduleFromPreset({
    required AlarmPreset preset,
    required DateTime date,
  }) async {
    final id = 'alarm_${DateTime.now().microsecondsSinceEpoch}';
    final alarm = _calc.scheduledFromPreset(
      preset: preset,
      date: date,
      questionLibrary: _repo.questions,
      id: id,
      qrPayload: _newQrPayload(id),
    );
    await _scheduler.schedule(alarm);
    await _repo.saveScheduled(alarm);
    state = _repo.scheduledAlarms;
    return alarm;
  }

  /// Create + schedule a one-off alarm.
  Future<ScheduledAlarm> scheduleOneOff({
    required DateTime anchorTime,
    required List<String> enabledQuestionIds,
    int? baseBufferMinutes,
    int? snoozeWindowMinutes,
    int? snoozeIntervalMinutes,
  }) async {
    final id = 'alarm_${DateTime.now().microsecondsSinceEpoch}';
    final alarm = _calc.scheduledOneOff(
      anchorTime: anchorTime,
      enabledQuestionIds: enabledQuestionIds,
      questionLibrary: _repo.questions,
      id: id,
      qrPayload: _newQrPayload(id),
      baseBufferMinutes: baseBufferMinutes ?? 30,
      snoozeWindowMinutes: snoozeWindowMinutes ?? 20,
      snoozeIntervalMinutes: snoozeIntervalMinutes ?? 5,
    );
    await _scheduler.schedule(alarm);
    await _repo.saveScheduled(alarm);
    state = _repo.scheduledAlarms;
    return alarm;
  }

  Future<void> snooze(String alarmId) async {
    final alarm = _repo.scheduledAlarm(alarmId);
    if (alarm == null) return;
    await _scheduler.snooze(alarm);
    await _repo.saveScheduled(alarm);
    state = _repo.scheduledAlarms;
  }

  /// Returns the dismiss result so the UI knows whether to launch the scanner.
  Future<DismissResult> dismiss(String alarmId, {String? scannedQrPayload}) async {
    final alarm = _repo.scheduledAlarm(alarmId);
    if (alarm == null) return DismissResult.dismissed;
    final result =
        await _scheduler.dismiss(alarm, scannedQrPayload: scannedQrPayload);
    if (result == DismissResult.dismissed) {
      await _repo.saveScheduled(alarm);
      state = _repo.scheduledAlarms;
    }
    return result;
  }

  Future<void> cancel(String alarmId) async {
    final alarm = _repo.scheduledAlarm(alarmId);
    if (alarm == null) return;
    await _scheduler.cancel(alarm);
    await _repo.deleteScheduled(alarmId);
    state = _repo.scheduledAlarms;
  }

  String _newQrPayload(String alarmId) => 'soup-alarm:$alarmId';
}
