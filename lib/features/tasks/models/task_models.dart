import 'package:hive/hive.dart';

part 'task_models.g.dart';

/// Where a task came from.
@HiveType(typeId: 10)
enum TaskSource {
  /// Imported from Google Calendar (fixed time, can't be moved).
  @HiveField(0)
  calendar,

  /// Chosen from a chore/hobby preset.
  @HiveField(1)
  preset,

  /// Manually added by the user.
  @HiveField(2)
  manual,

  /// A meal slot (lunch / dinner) inserted by the planner.
  @HiveField(3)
  meal,
}

/// High-level grouping used for presets + display.
@HiveType(typeId: 11)
enum TaskCategory {
  @HiveField(0)
  chore,
  @HiveField(1)
  hobby,
  @HiveField(2)
  meal,
  @HiveField(3)
  calendar,
  @HiveField(4)
  free,
}

/// Lifecycle of a task in the daily queue.
@HiveType(typeId: 12)
enum TaskStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
  /// Couldn't be fit into the day's free gaps by the scheduler.
  @HiveField(2)
  unscheduled,
}

/// A reusable chore/hobby template the user can slot into a day.
@HiveType(typeId: 13)
class TaskPreset extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  TaskCategory category;

  @HiveField(3)
  int estimatedMinutes;

  @HiveField(4)
  bool isCustom;

  TaskPreset({
    required this.id,
    required this.label,
    required this.category,
    required this.estimatedMinutes,
    this.isCustom = false,
  });
}

/// A concrete task in a specific day's queue.
@HiveType(typeId: 14)
class TaskItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  TaskCategory category;

  @HiveField(3)
  TaskSource source;

  @HiveField(4)
  int estimatedMinutes;

  /// Resolved start time once slotted into the day. Null while unscheduled.
  @HiveField(5)
  DateTime? scheduledStart;

  /// For calendar/meal items with a fixed window — the end time.
  @HiveField(6)
  DateTime? scheduledEnd;

  @HiveField(7)
  TaskStatus status;

  @HiveField(8)
  int kissesReward;

  /// The calendar day this task belongs to (date-only, local).
  @HiveField(9)
  DateTime day;

  /// Whether this item occupies a fixed time (calendar event / meal) and so
  /// must not be moved by the scheduler.
  @HiveField(10)
  bool isFixed;

  TaskItem({
    required this.id,
    required this.title,
    required this.category,
    required this.source,
    required this.estimatedMinutes,
    required this.day,
    this.scheduledStart,
    this.scheduledEnd,
    this.status = TaskStatus.pending,
    this.kissesReward = 0,
    this.isFixed = false,
  });

  TaskItem copyWith({
    String? title,
    TaskCategory? category,
    TaskSource? source,
    int? estimatedMinutes,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    TaskStatus? status,
    int? kissesReward,
    bool? isFixed,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      source: source ?? this.source,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      day: day,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      status: status ?? this.status,
      kissesReward: kissesReward ?? this.kissesReward,
      isFixed: isFixed ?? this.isFixed,
    );
  }
}

/// A lightweight calendar event used as a fixed "busy" block when planning.
/// Not persisted via Hive directly — produced by the calendar service.
class CalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
  });
}
