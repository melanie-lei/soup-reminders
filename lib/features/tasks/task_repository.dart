import 'package:hive/hive.dart';
import 'package:soup_reminders/core/constants.dart';
import 'package:soup_reminders/features/tasks/models/task_models.dart';

/// Hive-backed persistence for tasks + task presets.
class TaskRepository {
  TaskRepository({
    required Box<TaskItem> tasks,
    required Box<TaskPreset> presets,
  })  : _tasks = tasks,
        _presets = presets;

  final Box<TaskItem> _tasks;
  final Box<TaskPreset> _presets;

  /// Seed the built-in chore + hobby presets on first run.
  Future<void> seedDefaults() async {
    if (_presets.isNotEmpty) return;
    for (final c in DefaultTaskPresets.chores) {
      final id = 'chore_${c.label.toLowerCase().replaceAll(' ', '_')}';
      await _presets.put(
        id,
        TaskPreset(
          id: id,
          label: c.label,
          category: TaskCategory.chore,
          estimatedMinutes: c.minutes,
        ),
      );
    }
    for (final h in DefaultTaskPresets.hobbies) {
      final id = 'hobby_${h.label.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '_')}';
      await _presets.put(
        id,
        TaskPreset(
          id: id,
          label: h.label,
          category: TaskCategory.hobby,
          estimatedMinutes: h.minutes,
        ),
      );
    }
  }

  // ---- Presets ----
  List<TaskPreset> get presets => _presets.values.toList();

  Future<void> upsertPreset(TaskPreset preset) =>
      _presets.put(preset.id, preset);

  Future<void> deletePreset(String id) => _presets.delete(id);

  // ---- Tasks ----
  List<TaskItem> get allTasks => _tasks.values.toList();

  TaskItem? task(String id) => _tasks.get(id);

  /// Tasks for a given calendar day, ordered by start time (nulls last).
  List<TaskItem> tasksForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final list = _tasks.values
        .where((t) =>
            t.day.year == d.year && t.day.month == d.month && t.day.day == d.day)
        .toList();
    list.sort((a, b) {
      final sa = a.scheduledStart;
      final sb = b.scheduledStart;
      if (sa == null && sb == null) return 0;
      if (sa == null) return 1;
      if (sb == null) return -1;
      return sa.compareTo(sb);
    });
    return list;
  }

  Future<void> saveTask(TaskItem task) => _tasks.put(task.id, task);

  Future<void> saveAll(Iterable<TaskItem> tasks) async {
    await _tasks.putAll({for (final t in tasks) t.id: t});
  }

  Future<void> deleteTask(String id) => _tasks.delete(id);

  /// Remove all tasks for a day (used when re-planning).
  Future<void> clearDay(DateTime day) async {
    final ids = tasksForDay(day).map((t) => t.key).toList();
    await _tasks.deleteAll(ids);
  }
}
