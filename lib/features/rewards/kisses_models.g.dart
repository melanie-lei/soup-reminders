// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kisses_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KissTransactionAdapter extends TypeAdapter<KissTransaction> {
  @override
  final int typeId = 21;

  @override
  KissTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KissTransaction(
      id: fields[0] as String,
      amount: fields[1] as int,
      reason: fields[2] as KissReason,
      timestamp: fields[3] as DateTime,
      taskId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KissTransaction obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.reason)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.taskId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KissTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class KissReasonAdapter extends TypeAdapter<KissReason> {
  @override
  final int typeId = 20;

  @override
  KissReason read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return KissReason.taskCompleted;
      case 1:
        return KissReason.taskUncompleted;
      case 2:
        return KissReason.spent;
      case 3:
        return KissReason.manualAdjustment;
      default:
        return KissReason.taskCompleted;
    }
  }

  @override
  void write(BinaryWriter writer, KissReason obj) {
    switch (obj) {
      case KissReason.taskCompleted:
        writer.writeByte(0);
        break;
      case KissReason.taskUncompleted:
        writer.writeByte(1);
        break;
      case KissReason.spent:
        writer.writeByte(2);
        break;
      case KissReason.manualAdjustment:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KissReasonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
