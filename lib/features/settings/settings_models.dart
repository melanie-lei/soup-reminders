import 'package:hive/hive.dart';
import 'package:soup_reminders/core/constants.dart';

part 'settings_models.g.dart';

/// User-tunable app defaults. A single instance is stored under a fixed key.
@HiveType(typeId: 30)
class AppSettings extends HiveObject {
  @HiveField(0)
  int baseBufferMinutes;

  @HiveField(1)
  int snoozeWindowMinutes;

  @HiveField(2)
  int snoozeIntervalMinutes;

  @HiveField(3)
  int kissesPerTask;

  @HiveField(4)
  int lunchMinutesSinceMidnight;

  @HiveField(5)
  int dinnerMinutesSinceMidnight;

  @HiveField(6)
  int dayEndMinutes;

  AppSettings({
    this.baseBufferMinutes = AppDefaults.baseBufferMinutes,
    this.snoozeWindowMinutes = AppDefaults.snoozeWindowMinutes,
    this.snoozeIntervalMinutes = AppDefaults.snoozeIntervalMinutes,
    this.kissesPerTask = AppDefaults.kissesPerTask,
    this.lunchMinutesSinceMidnight = AppDefaults.defaultLunchMinutes,
    this.dinnerMinutesSinceMidnight = AppDefaults.defaultDinnerMinutes,
    this.dayEndMinutes = AppDefaults.dayEndMinutes,
  });

  static const String boxKey = 'app_settings';
}
