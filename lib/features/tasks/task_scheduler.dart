import 'package:soup_reminders/core/constants.dart';
import 'package:soup_reminders/features/tasks/models/task_models.dart';

/// A free interval in the day that flexible tasks can be slotted into.
class _Gap {
  DateTime start;
  final DateTime end;
  _Gap(this.start, this.end);

  /// Minutes of free space remaining, clamped at 0.
  int get freeMinutes {
    final m = end.difference(start).inMinutes;
    return m < 0 ? 0 : m;
  }
}

/// Request describing a day to plan.
class PlanRequest {
  /// The day being planned (date-only, local).
  final DateTime day;

  /// When the user is awake and able to start tasks (e.g. out-of-bed time).
  final DateTime dayStart;

  /// Latest time tasks may run until.
  final DateTime dayEnd;

  /// Fixed calendar events for the day (class, work, …).
  final List<CalendarEvent> calendarEvents;

  /// Flexible tasks (chores/hobbies/manual) the user wants to do.
  final List<TaskItem> flexibleTasks;

  /// Whether to auto-insert lunch + dinner meal slots.
  final bool includeMeals;

  final int lunchMinutesSinceMidnight;
  final int dinnerMinutesSinceMidnight;
  final int mealDurationMinutes;

  PlanRequest({
    required this.day,
    required this.dayStart,
    required this.dayEnd,
    required this.calendarEvents,
    required this.flexibleTasks,
    this.includeMeals = true,
    this.lunchMinutesSinceMidnight = AppDefaults.defaultLunchMinutes,
    this.dinnerMinutesSinceMidnight = AppDefaults.defaultDinnerMinutes,
    this.mealDurationMinutes = 30,
  });
}

/// Result of planning a day.
class PlanResult {
  /// All tasks, time-ordered, that were successfully placed (incl. fixed ones).
  final List<TaskItem> scheduled;

  /// Flexible tasks that didn't fit in any free gap.
  final List<TaskItem> overflow;

  const PlanResult({required this.scheduled, required this.overflow});
}

/// Greedy day planner: places fixed calendar events + meals, then slots
/// flexible tasks into the remaining free gaps in order.
///
/// Pure (no I/O) so it can be unit-tested directly.
class TaskScheduler {
  const TaskScheduler();

  PlanResult plan(PlanRequest req) {
    // 1. Collect fixed blocks (calendar events + optional meals) as TaskItems.
    final fixed = <TaskItem>[];

    for (final e in req.calendarEvents) {
      fixed.add(TaskItem(
        id: 'cal_${e.id}',
        title: e.title,
        category: TaskCategory.calendar,
        source: TaskSource.calendar,
        estimatedMinutes: e.end.difference(e.start).inMinutes,
        day: req.day,
        scheduledStart: e.start,
        scheduledEnd: e.end,
        isFixed: true,
      ));
    }

    if (req.includeMeals) {
      fixed.add(_meal('Lunch', req, req.lunchMinutesSinceMidnight));
      fixed.add(_meal('Dinner', req, req.dinnerMinutesSinceMidnight));
    }

    fixed.sort((a, b) => a.scheduledStart!.compareTo(b.scheduledStart!));

    // 2. Compute free gaps between fixed blocks within [dayStart, dayEnd].
    final gaps = _computeGaps(req.dayStart, req.dayEnd, fixed);

    // 3. Greedily place flexible tasks into gaps (first-fit, in order).
    final placed = <TaskItem>[...fixed];
    final overflow = <TaskItem>[];

    for (final task in req.flexibleTasks) {
      final gap = _firstFit(gaps, task.estimatedMinutes);
      if (gap == null) {
        overflow.add(task.copyWith(status: TaskStatus.unscheduled));
        continue;
      }
      final start = gap.start;
      final end = start.add(Duration(minutes: task.estimatedMinutes));
      placed.add(task.copyWith(
        scheduledStart: start,
        scheduledEnd: end,
        status: TaskStatus.pending,
      ));
      gap.start = end; // shrink the gap for the next task
    }

    placed.sort((a, b) => a.scheduledStart!.compareTo(b.scheduledStart!));
    return PlanResult(scheduled: placed, overflow: overflow);
  }

  TaskItem _meal(String title, PlanRequest req, int minutesSinceMidnight) {
    final start = DateTime(
      req.day.year,
      req.day.month,
      req.day.day,
      minutesSinceMidnight ~/ 60,
      minutesSinceMidnight % 60,
    );
    return TaskItem(
      id: 'meal_${title.toLowerCase()}',
      title: title,
      category: TaskCategory.meal,
      source: TaskSource.meal,
      estimatedMinutes: req.mealDurationMinutes,
      day: req.day,
      scheduledStart: start,
      scheduledEnd: start.add(Duration(minutes: req.mealDurationMinutes)),
      isFixed: true,
    );
  }

  List<_Gap> _computeGaps(
    DateTime dayStart,
    DateTime dayEnd,
    List<TaskItem> fixedSorted,
  ) {
    final gaps = <_Gap>[];
    var cursor = dayStart;
    for (final block in fixedSorted) {
      final bStart = block.scheduledStart!;
      final bEnd = block.scheduledEnd ?? bStart;
      if (bStart.isAfter(cursor)) {
        gaps.add(_Gap(cursor, bStart.isBefore(dayEnd) ? bStart : dayEnd));
      }
      if (bEnd.isAfter(cursor)) cursor = bEnd;
    }
    if (cursor.isBefore(dayEnd)) gaps.add(_Gap(cursor, dayEnd));
    return gaps.where((g) => g.freeMinutes > 0).toList();
  }

  _Gap? _firstFit(List<_Gap> gaps, int minutes) {
    for (final g in gaps) {
      if (g.freeMinutes >= minutes) return g;
    }
    return null;
  }
}
