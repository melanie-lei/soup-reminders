import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soup_reminders/core/constants.dart';
import 'package:soup_reminders/features/alarm/alarm_providers.dart'
    show notificationServiceProvider;
import 'package:soup_reminders/features/rewards/kisses_providers.dart';
import 'package:soup_reminders/features/tasks/models/task_models.dart';
import 'package:soup_reminders/features/tasks/task_reminder_service.dart';
import 'package:soup_reminders/features/tasks/task_repository.dart';
import 'package:soup_reminders/features/tasks/task_scheduler.dart';

/// Provides the [TaskRepository]. Overridden in `main` once Hive opens.
final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => throw UnimplementedError('taskRepositoryProvider must be '
      'overridden in ProviderScope'),
);

final taskSchedulerProvider =
    Provider<TaskScheduler>((ref) => const TaskScheduler());

final taskReminderServiceProvider = Provider<TaskReminderService>(
  (ref) => TaskReminderService(ref.watch(notificationServiceProvider)),
);

/// Task presets (chores + hobbies).
final taskPresetsProvider =
    NotifierProvider<TaskPresetsNotifier, List<TaskPreset>>(
  TaskPresetsNotifier.new,
);

class TaskPresetsNotifier extends Notifier<List<TaskPreset>> {
  @override
  List<TaskPreset> build() => ref.watch(taskRepositoryProvider).presets;

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  List<TaskPreset> get chores =>
      state.where((p) => p.category == TaskCategory.chore).toList();

  List<TaskPreset> get hobbies =>
      state.where((p) => p.category == TaskCategory.hobby).toList();

  Future<void> addCustom({
    required String label,
    required TaskCategory category,
    required int estimatedMinutes,
  }) async {
    final preset = TaskPreset(
      id: 'preset_${DateTime.now().microsecondsSinceEpoch}',
      label: label,
      category: category,
      estimatedMinutes: estimatedMinutes,
      isCustom: true,
    );
    await _repo.upsertPreset(preset);
    state = _repo.presets;
  }

  Future<void> remove(String id) async {
    await _repo.deletePreset(id);
    state = _repo.presets;
  }
}

/// The currently-viewed day for the task list. Defaults to today.
final selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// The task queue for [selectedDayProvider], with completion + planning logic.
final dayTasksProvider =
    NotifierProvider<DayTasksNotifier, List<TaskItem>>(DayTasksNotifier.new);

class DayTasksNotifier extends Notifier<List<TaskItem>> {
  @override
  List<TaskItem> build() {
    final day = ref.watch(selectedDayProvider);
    return ref.watch(taskRepositoryProvider).tasksForDay(day);
  }

  TaskRepository get _repo => ref.read(taskRepositoryProvider);
  DateTime get _day => ref.read(selectedDayProvider);

  /// The next upcoming, still-pending task (the one to highlight on home).
  TaskItem? get upcoming {
    final pending = state
        .where((t) => t.status == TaskStatus.pending && t.scheduledStart != null)
        .toList()
      ..sort((a, b) => a.scheduledStart!.compareTo(b.scheduledStart!));
    return pending.isEmpty ? null : pending.first;
  }

  /// Build the day from calendar events + chosen flexible tasks, persist it,
  /// and schedule reminder notifications.
  Future<PlanResult> planDay({
    required DateTime dayStart,
    required List<CalendarEvent> calendarEvents,
    required List<TaskItem> flexibleTasks,
    bool includeMeals = true,
    DateTime? dayEnd,
  }) async {
    final end = dayEnd ??
        DateTime(_day.year, _day.month, _day.day,
            AppDefaults.dayEndMinutes ~/ 60, AppDefaults.dayEndMinutes % 60);

    final result = ref.read(taskSchedulerProvider).plan(PlanRequest(
          day: _day,
          dayStart: dayStart,
          dayEnd: end,
          calendarEvents: calendarEvents,
          flexibleTasks: flexibleTasks,
          includeMeals: includeMeals,
        ));

    // Award is configured per task; non-fixed tasks earn kisses.
    final toSave = [
      for (final t in result.scheduled)
        t.isFixed ? t : t.copyWith(kissesReward: AppDefaults.kissesPerTask),
      ...result.overflow,
    ];

    await _repo.clearDay(_day);
    await _repo.saveAll(toSave);

    state = _repo.tasksForDay(_day);

    await ref.read(taskReminderServiceProvider).scheduleForDay(state);
    return result;
  }

  /// Add a single ad-hoc task to the current day (unscheduled until planned).
  Future<void> addTask(TaskItem task) async {
    await _repo.saveTask(task);
    state = _repo.tasksForDay(_day);
  }

  /// Check off a task: mark completed, award kisses, cancel its reminder.
  Future<void> complete(String taskId) async {
    final task = _repo.task(taskId);
    if (task == null || task.status == TaskStatus.completed) return;
    task.status = TaskStatus.completed;
    await _repo.saveTask(task);
    await ref.read(taskReminderServiceProvider).cancel(task);
    if (!task.isFixed && task.kissesReward > 0) {
      await ref
          .read(kissesBalanceProvider.notifier)
          .award(amount: task.kissesReward, taskId: task.id);
    }
    state = _repo.tasksForDay(_day);
  }

  /// Undo completion: restore pending state and reverse the kisses award.
  Future<void> uncomplete(String taskId) async {
    final task = _repo.task(taskId);
    if (task == null || task.status != TaskStatus.completed) return;
    task.status = TaskStatus.pending;
    await _repo.saveTask(task);
    if (!task.isFixed && task.kissesReward > 0) {
      await ref.read(kissesBalanceProvider.notifier).reverseForTask(task.id);
    }
    state = _repo.tasksForDay(_day);
  }

  Future<void> remove(String taskId) async {
    final task = _repo.task(taskId);
    if (task != null) {
      await ref.read(taskReminderServiceProvider).cancel(task);
    }
    await _repo.deleteTask(taskId);
    state = _repo.tasksForDay(_day);
  }
}

/// Convenience provider exposing just the next task (for the home-screen widget
/// + highlighted card). See [DayTasksNotifier.upcoming].
final upcomingTaskProvider = Provider<TaskItem?>((ref) {
  ref.watch(dayTasksProvider);
  return ref.read(dayTasksProvider.notifier).upcoming;
});
