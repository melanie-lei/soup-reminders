/// App-wide default values and tuning constants.
///
/// These are defaults only — most are overridable per-alarm or via
/// [AppSettings] so the user can tweak them in the UI later.
class AppDefaults {
  AppDefaults._();

  // ---- Alarm ----
  /// Base buffer: "get up 30 minutes before leaving".
  static const int baseBufferMinutes = 30;

  /// Total snooze window allowed before escalation kicks in.
  static const int snoozeWindowMinutes = 20;

  /// Length of a single snooze interval.
  static const int snoozeIntervalMinutes = 5;

  /// Derived: how many snoozes are allowed before escalation (20 / 5 = 4).
  static int get maxSnoozes => snoozeWindowMinutes ~/ snoozeIntervalMinutes;

  // ---- Tasks / rewards ----
  /// Kisses awarded for completing a single task.
  static const int kissesPerTask = 5;

  /// Default estimated duration for a task with no explicit estimate.
  static const int defaultTaskMinutes = 30;

  /// Default time-of-day (minutes since midnight) for meal slots.
  static const int defaultLunchMinutes = 12 * 60; // 12:00
  static const int defaultDinnerMinutes = 18 * 60; // 18:00

  /// Default planning-day window end (tasks won't be scheduled past this).
  static const int dayEndMinutes = 22 * 60; // 22:00
}

/// Default alarm personalization questions, per the product spec.
///
/// Each adds time on top of the base buffer when enabled.
class DefaultAlarmQuestions {
  DefaultAlarmQuestions._();

  static const String makeupId = 'q_makeup';
  static const String lunchId = 'q_lunch';
  static const String prepId = 'q_prep';

  /// (id, label, minutesAdded) tuples used to seed the question library.
  static const List<({String id, String label, int minutes})> seed = [
    (id: makeupId, label: 'Are you doing makeup?', minutes: 25),
    (id: lunchId, label: 'Do you have to make lunch?', minutes: 15),
    (id: prepId, label: 'Do you have to pack/prepare anything?', minutes: 10),
  ];
}

/// Default chore + hobby task presets, per the product spec.
class DefaultTaskPresets {
  DefaultTaskPresets._();

  static const List<({String label, int minutes})> chores = [
    (label: 'Clean desk', minutes: 15),
    (label: 'Clean room', minutes: 30),
    (label: 'Laundry', minutes: 60),
    (label: 'Clean bathroom', minutes: 30),
  ];

  static const List<({String label, int minutes})> hobbies = [
    (label: 'Crochet', minutes: 60),
    (label: 'Free/unscheduled time', minutes: 30),
  ];
}

/// Names of the Hive boxes used across the app.
class HiveBoxes {
  HiveBoxes._();

  static const String alarmQuestions = 'alarm_questions';
  static const String alarmPresets = 'alarm_presets';
  static const String scheduledAlarms = 'scheduled_alarms';
  static const String tasks = 'tasks';
  static const String taskPresets = 'task_presets';
  static const String kissTransactions = 'kiss_transactions';
  static const String settings = 'settings';
}
