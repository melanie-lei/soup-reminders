import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soup_reminders/features/alarm/alarm_providers.dart';
import 'package:soup_reminders/features/alarm/models/alarm_models.dart';
import 'package:soup_reminders/features/calendar/calendar_providers.dart';
import 'package:soup_reminders/features/tasks/models/task_models.dart';
import 'package:soup_reminders/features/tasks/task_providers.dart';

/// The two-step "plan for the next day" flow from the product spec:
///   1. decide the wake-up alarm  (alarm setting sequence)
///   2. decide tasks (import calendar + slot chosen tasks)
enum PlanStep { alarm, tasks, done }

/// Immutable snapshot of an in-progress planning session.
class PlanningState {
  /// The day being planned (date-only).
  final DateTime day;
  final PlanStep step;

  /// The alarm created in step 1 (null until set).
  final ScheduledAlarm? alarm;

  /// Whether step 2's task plan has been committed.
  final bool tasksPlanned;

  const PlanningState({
    required this.day,
    this.step = PlanStep.alarm,
    this.alarm,
    this.tasksPlanned = false,
  });

  PlanningState copyWith({
    PlanStep? step,
    ScheduledAlarm? alarm,
    bool? tasksPlanned,
  }) {
    return PlanningState(
      day: day,
      step: step ?? this.step,
      alarm: alarm ?? this.alarm,
      tasksPlanned: tasksPlanned ?? this.tasksPlanned,
    );
  }
}

/// Orchestrates planning for a target day. Created with [PlanningController.start].
final planningControllerProvider =
    NotifierProvider<PlanningController, PlanningState?>(PlanningController.new);

class PlanningController extends Notifier<PlanningState?> {
  @override
  PlanningState? build() => null;

  /// Begin planning for [day] (defaults to tomorrow).
  void start({DateTime? day}) {
    final target = day ??
        () {
          final t = DateTime.now().add(const Duration(days: 1));
          return DateTime(t.year, t.month, t.day);
        }();
    state = PlanningState(day: target);
  }

  /// Step 1 — set the alarm from a preset.
  Future<void> setAlarmFromPreset(AlarmPreset preset) async {
    final s = state;
    if (s == null) return;
    final alarm = await ref
        .read(scheduledAlarmsProvider.notifier)
        .scheduleFromPreset(preset: preset, date: s.day);
    state = s.copyWith(alarm: alarm, step: PlanStep.tasks);
  }

  /// Step 1 — set a one-off alarm.
  Future<void> setOneOffAlarm({
    required DateTime anchorTime,
    required List<String> enabledQuestionIds,
  }) async {
    final s = state;
    if (s == null) return;
    final alarm = await ref.read(scheduledAlarmsProvider.notifier).scheduleOneOff(
          anchorTime: anchorTime,
          enabledQuestionIds: enabledQuestionIds,
        );
    state = s.copyWith(alarm: alarm, step: PlanStep.tasks);
  }

  /// Step 2 — pull calendar events for the day so the UI can show fixed blocks.
  Future<List<CalendarEvent>> loadCalendarEvents() async {
    final s = state;
    if (s == null) return const [];
    return ref.read(calendarEventsProvider(s.day).future);
  }

  /// Build flexible [TaskItem]s from chosen presets for the planned day.
  List<TaskItem> tasksFromPresets(List<TaskPreset> chosen) {
    final s = state;
    if (s == null) return const [];
    return [
      for (final p in chosen)
        TaskItem(
          id: 'task_${p.id}_${DateTime.now().microsecondsSinceEpoch}',
          title: p.label,
          category: p.category,
          source: TaskSource.preset,
          estimatedMinutes: p.estimatedMinutes,
          day: s.day,
        ),
    ];
  }

  /// Step 2 — commit the task plan. Uses the alarm's out-of-bed time as the
  /// start of the usable day when available.
  Future<void> commitTasks({
    required List<CalendarEvent> calendarEvents,
    required List<TaskItem> flexibleTasks,
    bool includeMeals = true,
  }) async {
    final s = state;
    if (s == null) return;

    // Make sure the day-tasks notifier targets the planned day.
    ref.read(selectedDayProvider.notifier).state = s.day;

    final dayStart = s.alarm?.outOfBedTime ??
        DateTime(s.day.year, s.day.month, s.day.day, 8);

    await ref.read(dayTasksProvider.notifier).planDay(
          dayStart: dayStart,
          calendarEvents: calendarEvents,
          flexibleTasks: flexibleTasks,
          includeMeals: includeMeals,
        );

    state = s.copyWith(tasksPlanned: true, step: PlanStep.done);
  }

  void cancel() => state = null;
}
