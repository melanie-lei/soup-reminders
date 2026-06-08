import 'package:hive/hive.dart';
import 'package:soup_reminders/features/rewards/kisses_models.dart';

/// Hive-backed kisses ledger. Balance is derived from the sum of transactions
/// so it can never drift out of sync.
class KissesRepository {
  KissesRepository(this._transactions);

  final Box<KissTransaction> _transactions;

  int get balance =>
      _transactions.values.fold(0, (sum, t) => sum + t.amount);

  List<KissTransaction> get transactions {
    final list = _transactions.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<KissTransaction> add({
    required int amount,
    required KissReason reason,
    String? taskId,
  }) async {
    final tx = KissTransaction(
      id: 'kiss_${DateTime.now().microsecondsSinceEpoch}',
      amount: amount,
      reason: reason,
      timestamp: DateTime.now(),
      taskId: taskId,
    );
    await _transactions.put(tx.id, tx);
    return tx;
  }

  /// Reverse the award for a task (used when a task is un-checked). Removes the
  /// most recent positive entry tied to [taskId], if any.
  Future<void> reverseForTask(String taskId) async {
    final award = _transactions.values
        .where((t) => t.taskId == taskId && t.amount > 0)
        .fold<KissTransaction?>(null, (latest, t) {
      if (latest == null || t.timestamp.isAfter(latest.timestamp)) return t;
      return latest;
    });
    if (award != null) {
      await add(
        amount: -award.amount,
        reason: KissReason.taskUncompleted,
        taskId: taskId,
      );
    }
  }
}
