import 'package:soup_reminders/features/tasks/models/task_models.dart';
import 'package:soup_reminders/services/notification_service.dart';

/// Builds nudge text for tasks and schedules their reminder notifications.
class TaskReminderService {
  TaskReminderService(this._notifications);

  final NotificationService _notifications;

  int _notificationId(TaskItem task) => task.id.hashCode & 0x7fffffff;

  /// Schedule reminders for every pending, time-slotted task in [orderedTasks].
  ///
  /// Cancels any previously scheduled reminder for each task first so re-planning
  /// is idempotent.
  Future<void> scheduleForDay(List<TaskItem> orderedTasks) async {
    final timed = orderedTasks
        .where((t) =>
            t.scheduledStart != null &&
            t.status == TaskStatus.pending &&
            !t.isFixed)
        .toList();

    for (var i = 0; i < timed.length; i++) {
      final task = timed[i];
      await _notifications.cancel(_notificationId(task));
      // Don't schedule reminders for times already in the past.
      if (task.scheduledStart!.isBefore(DateTime.now())) continue;

      await _notifications.scheduleTaskReminder(
        id: _notificationId(task),
        when: task.scheduledStart!,
        title: nudgeTitle(task),
        body: nudgeBody(task, previous: i > 0 ? timed[i - 1] : null),
        payload: 'task:${task.id}',
      );
    }
  }

  Future<void> cancel(TaskItem task) =>
      _notifications.cancel(_notificationId(task));

  /// e.g. "It's time to clean your desk!"
  String nudgeTitle(TaskItem task) {
    final lower = task.title.substring(0, 1).toLowerCase() + task.title.substring(1);
    return "It's time to $lower!";
  }

  /// Adds a contextual nudge — if the previous slot was a meal, ask whether the
  /// user has eaten (matches the product spec example).
  String nudgeBody(TaskItem task, {TaskItem? previous}) {
    if (previous != null && previous.category == TaskCategory.meal) {
      return 'Have you eaten ${previous.title.toLowerCase()} yet? '
          'Then get to it — worth ${task.kissesReward} kisses 💋';
    }
    return 'Worth ${task.kissesReward} kisses 💋';
  }
}
