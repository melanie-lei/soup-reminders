import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:soup_reminders/features/settings/settings_models.dart';

/// Provides the opened settings [Box]. Overridden in `main`.
final settingsBoxProvider = Provider<Box<AppSettings>>(
  (ref) => throw UnimplementedError('settingsBoxProvider must be overridden'),
);

/// Current app settings, persisted to Hive under a fixed key.
final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final box = ref.watch(settingsBoxProvider);
    final existing = box.get(AppSettings.boxKey);
    if (existing != null) return existing;
    final fresh = AppSettings();
    box.put(AppSettings.boxKey, fresh);
    return fresh;
  }

  Future<void> save(AppSettings settings) async {
    await ref.read(settingsBoxProvider).put(AppSettings.boxKey, settings);
    state = settings;
  }
}
