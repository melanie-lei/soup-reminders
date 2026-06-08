import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soup_reminders/features/rewards/kisses_models.dart';
import 'package:soup_reminders/features/rewards/kisses_repository.dart';

/// Provides the [KissesRepository]. Overridden in `main` once Hive opens.
final kissesRepositoryProvider = Provider<KissesRepository>(
  (ref) => throw UnimplementedError('kissesRepositoryProvider must be '
      'overridden in ProviderScope'),
);

/// Current kisses balance, recomputed from the ledger.
final kissesBalanceProvider =
    NotifierProvider<KissesBalanceNotifier, int>(KissesBalanceNotifier.new);

class KissesBalanceNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(kissesRepositoryProvider).balance;

  KissesRepository get _repo => ref.read(kissesRepositoryProvider);

  Future<void> award({required int amount, String? taskId}) async {
    await _repo.add(
      amount: amount,
      reason: KissReason.taskCompleted,
      taskId: taskId,
    );
    state = _repo.balance;
  }

  Future<void> reverseForTask(String taskId) async {
    await _repo.reverseForTask(taskId);
    state = _repo.balance;
  }

  Future<void> adjust(int amount) async {
    await _repo.add(amount: amount, reason: KissReason.manualAdjustment);
    state = _repo.balance;
  }
}

/// Full ledger for a history screen.
final kissesLedgerProvider = Provider<List<KissTransaction>>(
  (ref) {
    ref.watch(kissesBalanceProvider); // rebuild when balance changes
    return ref.watch(kissesRepositoryProvider).transactions;
  },
);
