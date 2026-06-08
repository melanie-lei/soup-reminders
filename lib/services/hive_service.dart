import 'package:hive_flutter/hive_flutter.dart';
import 'package:soup_reminders/core/constants.dart';
import 'package:soup_reminders/features/alarm/models/alarm_models.dart';
import 'package:soup_reminders/features/rewards/kisses_models.dart';
import 'package:soup_reminders/features/settings/settings_models.dart';
import 'package:soup_reminders/features/tasks/models/task_models.dart';

/// Opened Hive boxes, passed to the repositories via provider overrides.
class HiveBoxesBundle {
  final Box<AlarmQuestion> alarmQuestions;
  final Box<AlarmPreset> alarmPresets;
  final Box<ScheduledAlarm> scheduledAlarms;
  final Box<TaskItem> tasks;
  final Box<TaskPreset> taskPresets;
  final Box<KissTransaction> kissTransactions;
  final Box<AppSettings> settings;

  const HiveBoxesBundle({
    required this.alarmQuestions,
    required this.alarmPresets,
    required this.scheduledAlarms,
    required this.tasks,
    required this.taskPresets,
    required this.kissTransactions,
    required this.settings,
  });
}

/// Initializes Hive, registers all generated adapters, and opens every box.
class HiveService {
  const HiveService();

  Future<HiveBoxesBundle> init() async {
    await Hive.initFlutter();
    _registerAdapters();

    final bundle = HiveBoxesBundle(
      alarmQuestions:
          await Hive.openBox<AlarmQuestion>(HiveBoxes.alarmQuestions),
      alarmPresets: await Hive.openBox<AlarmPreset>(HiveBoxes.alarmPresets),
      scheduledAlarms:
          await Hive.openBox<ScheduledAlarm>(HiveBoxes.scheduledAlarms),
      tasks: await Hive.openBox<TaskItem>(HiveBoxes.tasks),
      taskPresets: await Hive.openBox<TaskPreset>(HiveBoxes.taskPresets),
      kissTransactions:
          await Hive.openBox<KissTransaction>(HiveBoxes.kissTransactions),
      settings: await Hive.openBox<AppSettings>(HiveBoxes.settings),
    );
    return bundle;
  }

  void _registerAdapters() {
    Hive
      ..registerAdapter(AlarmQuestionAdapter())
      ..registerAdapter(AlarmPresetAdapter())
      ..registerAdapter(AlarmRunStateAdapter())
      ..registerAdapter(ScheduledAlarmAdapter())
      ..registerAdapter(TaskSourceAdapter())
      ..registerAdapter(TaskCategoryAdapter())
      ..registerAdapter(TaskStatusAdapter())
      ..registerAdapter(TaskPresetAdapter())
      ..registerAdapter(TaskItemAdapter())
      ..registerAdapter(KissReasonAdapter())
      ..registerAdapter(KissTransactionAdapter())
      ..registerAdapter(AppSettingsAdapter());
  }
}
