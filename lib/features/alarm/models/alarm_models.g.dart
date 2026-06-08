// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmQuestionAdapter extends TypeAdapter<AlarmQuestion> {
  @override
  final int typeId = 0;

  @override
  AlarmQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmQuestion(
      id: fields[0] as String,
      label: fields[1] as String,
      addedMinutes: fields[2] as int,
      isCustom: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmQuestion obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.addedMinutes)
      ..writeByte(3)
      ..write(obj.isCustom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmQuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlarmPresetAdapter extends TypeAdapter<AlarmPreset> {
  @override
  final int typeId = 1;

  @override
  AlarmPreset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmPreset(
      id: fields[0] as String,
      name: fields[1] as String,
      anchorMinutesSinceMidnight: fields[2] as int,
      enabledQuestionIds: (fields[3] as List).cast<String>(),
      baseBufferMinutes: fields[4] as int,
      snoozeWindowMinutes: fields[5] as int,
      snoozeIntervalMinutes: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmPreset obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.anchorMinutesSinceMidnight)
      ..writeByte(3)
      ..write(obj.enabledQuestionIds)
      ..writeByte(4)
      ..write(obj.baseBufferMinutes)
      ..writeByte(5)
      ..write(obj.snoozeWindowMinutes)
      ..writeByte(6)
      ..write(obj.snoozeIntervalMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmPresetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScheduledAlarmAdapter extends TypeAdapter<ScheduledAlarm> {
  @override
  final int typeId = 3;

  @override
  ScheduledAlarm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduledAlarm(
      id: fields[0] as String,
      anchorTime: fields[1] as DateTime,
      outOfBedTime: fields[2] as DateTime,
      firstRingTime: fields[3] as DateTime,
      snoozeIntervalMinutes: fields[4] as int,
      maxSnoozes: fields[5] as int,
      escalationQrPayload: fields[8] as String,
      prepMinutes: fields[9] as int,
      snoozeCount: fields[6] as int,
      state: fields[7] as AlarmRunState,
      presetId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduledAlarm obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.anchorTime)
      ..writeByte(2)
      ..write(obj.outOfBedTime)
      ..writeByte(3)
      ..write(obj.firstRingTime)
      ..writeByte(4)
      ..write(obj.snoozeIntervalMinutes)
      ..writeByte(5)
      ..write(obj.maxSnoozes)
      ..writeByte(6)
      ..write(obj.snoozeCount)
      ..writeByte(7)
      ..write(obj.state)
      ..writeByte(8)
      ..write(obj.escalationQrPayload)
      ..writeByte(9)
      ..write(obj.prepMinutes)
      ..writeByte(10)
      ..write(obj.presetId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledAlarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlarmRunStateAdapter extends TypeAdapter<AlarmRunState> {
  @override
  final int typeId = 2;

  @override
  AlarmRunState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlarmRunState.scheduled;
      case 1:
        return AlarmRunState.ringing;
      case 2:
        return AlarmRunState.snoozed;
      case 3:
        return AlarmRunState.escalated;
      case 4:
        return AlarmRunState.dismissed;
      default:
        return AlarmRunState.scheduled;
    }
  }

  @override
  void write(BinaryWriter writer, AlarmRunState obj) {
    switch (obj) {
      case AlarmRunState.scheduled:
        writer.writeByte(0);
        break;
      case AlarmRunState.ringing:
        writer.writeByte(1);
        break;
      case AlarmRunState.snoozed:
        writer.writeByte(2);
        break;
      case AlarmRunState.escalated:
        writer.writeByte(3);
        break;
      case AlarmRunState.dismissed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmRunStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
