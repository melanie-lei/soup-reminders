// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskPresetAdapter extends TypeAdapter<TaskPreset> {
  @override
  final int typeId = 13;

  @override
  TaskPreset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskPreset(
      id: fields[0] as String,
      label: fields[1] as String,
      category: fields[2] as TaskCategory,
      estimatedMinutes: fields[3] as int,
      isCustom: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskPreset obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.estimatedMinutes)
      ..writeByte(4)
      ..write(obj.isCustom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPresetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskItemAdapter extends TypeAdapter<TaskItem> {
  @override
  final int typeId = 14;

  @override
  TaskItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskItem(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as TaskCategory,
      source: fields[3] as TaskSource,
      estimatedMinutes: fields[4] as int,
      day: fields[9] as DateTime,
      scheduledStart: fields[5] as DateTime?,
      scheduledEnd: fields[6] as DateTime?,
      status: fields[7] as TaskStatus,
      kissesReward: fields[8] as int,
      isFixed: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.source)
      ..writeByte(4)
      ..write(obj.estimatedMinutes)
      ..writeByte(5)
      ..write(obj.scheduledStart)
      ..writeByte(6)
      ..write(obj.scheduledEnd)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.kissesReward)
      ..writeByte(9)
      ..write(obj.day)
      ..writeByte(10)
      ..write(obj.isFixed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskSourceAdapter extends TypeAdapter<TaskSource> {
  @override
  final int typeId = 10;

  @override
  TaskSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskSource.calendar;
      case 1:
        return TaskSource.preset;
      case 2:
        return TaskSource.manual;
      case 3:
        return TaskSource.meal;
      default:
        return TaskSource.calendar;
    }
  }

  @override
  void write(BinaryWriter writer, TaskSource obj) {
    switch (obj) {
      case TaskSource.calendar:
        writer.writeByte(0);
        break;
      case TaskSource.preset:
        writer.writeByte(1);
        break;
      case TaskSource.manual:
        writer.writeByte(2);
        break;
      case TaskSource.meal:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskCategoryAdapter extends TypeAdapter<TaskCategory> {
  @override
  final int typeId = 11;

  @override
  TaskCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskCategory.chore;
      case 1:
        return TaskCategory.hobby;
      case 2:
        return TaskCategory.meal;
      case 3:
        return TaskCategory.calendar;
      case 4:
        return TaskCategory.free;
      default:
        return TaskCategory.chore;
    }
  }

  @override
  void write(BinaryWriter writer, TaskCategory obj) {
    switch (obj) {
      case TaskCategory.chore:
        writer.writeByte(0);
        break;
      case TaskCategory.hobby:
        writer.writeByte(1);
        break;
      case TaskCategory.meal:
        writer.writeByte(2);
        break;
      case TaskCategory.calendar:
        writer.writeByte(3);
        break;
      case TaskCategory.free:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 12;

  @override
  TaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskStatus.pending;
      case 1:
        return TaskStatus.completed;
      case 2:
        return TaskStatus.unscheduled;
      default:
        return TaskStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    switch (obj) {
      case TaskStatus.pending:
        writer.writeByte(0);
        break;
      case TaskStatus.completed:
        writer.writeByte(1);
        break;
      case TaskStatus.unscheduled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
