import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soup_reminders/features/alarm/alarm_providers.dart';
import 'package:soup_reminders/features/alarm/alarm_repository.dart';
import 'package:soup_reminders/features/rewards/kisses_providers.dart';
import 'package:soup_reminders/features/rewards/kisses_repository.dart';
import 'package:soup_reminders/features/settings/settings_providers.dart';
import 'package:soup_reminders/features/tasks/task_providers.dart';
import 'package:soup_reminders/features/tasks/task_repository.dart';
import 'package:soup_reminders/services/hive_service.dart';
import 'package:soup_reminders/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Storage.
  final boxes = await const HiveService().init();

  // 2. Notifications.
  final notifications = NotificationService(FlutterLocalNotificationsPlugin());
  await notifications.init();

  // 3. Repositories.
  final alarmRepo = AlarmRepository(
    questions: boxes.alarmQuestions,
    presets: boxes.alarmPresets,
    scheduled: boxes.scheduledAlarms,
  );
  final taskRepo = TaskRepository(
    tasks: boxes.tasks,
    presets: boxes.taskPresets,
  );
  final kissesRepo = KissesRepository(boxes.kissTransactions);

  // 4. Seed built-in questions + chore/hobby presets on first run.
  await alarmRepo.seedDefaults();
  await taskRepo.seedDefaults();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notifications),
        alarmRepositoryProvider.overrideWithValue(alarmRepo),
        taskRepositoryProvider.overrideWithValue(taskRepo),
        kissesRepositoryProvider.overrideWithValue(kissesRepo),
        settingsBoxProvider.overrideWithValue(boxes.settings),
      ],
      child: const SoupRemindersApp(),
    ),
  );
}

class SoupRemindersApp extends StatelessWidget {
  const SoupRemindersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soup Reminders',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _BackendSmokeScreen(),
    );
  }
}

/// Temporary placeholder screen until the Figma UI lands. Surfaces the live
/// kisses balance + next task so the wired-up backend is visible end-to-end.
class _BackendSmokeScreen extends ConsumerWidget {
  const _BackendSmokeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(kissesBalanceProvider);
    final upcoming = ref.watch(upcomingTaskProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Soup Reminders')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💋 $balance kisses',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(upcoming == null
                ? 'No upcoming task — plan your day!'
                : 'Next: ${upcoming.title}'),
            const SizedBox(height: 24),
            const Text('Backend wired up. UI coming from Figma.'),
          ],
        ),
      ),
    );
  }
}
