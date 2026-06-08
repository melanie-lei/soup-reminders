import 'package:hive/hive.dart';

part 'kisses_models.g.dart';

/// Why kisses were added or removed.
@HiveType(typeId: 20)
enum KissReason {
  @HiveField(0)
  taskCompleted,
  @HiveField(1)
  taskUncompleted,
  @HiveField(2)
  spent,
  @HiveField(3)
  manualAdjustment,
}

/// An immutable ledger entry in the kisses wallet.
@HiveType(typeId: 21)
class KissTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  /// Signed delta: +5 for a completed task, -N for spending, etc.
  @HiveField(1)
  final int amount;

  @HiveField(2)
  final KissReason reason;

  @HiveField(3)
  final DateTime timestamp;

  /// Optional reference to the task that triggered this entry.
  @HiveField(4)
  final String? taskId;

  KissTransaction({
    required this.id,
    required this.amount,
    required this.reason,
    required this.timestamp,
    this.taskId,
  });
}
