// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 30;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      baseBufferMinutes: fields[0] as int,
      snoozeWindowMinutes: fields[1] as int,
      snoozeIntervalMinutes: fields[2] as int,
      kissesPerTask: fields[3] as int,
      lunchMinutesSinceMidnight: fields[4] as int,
      dinnerMinutesSinceMidnight: fields[5] as int,
      dayEndMinutes: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.baseBufferMinutes)
      ..writeByte(1)
      ..write(obj.snoozeWindowMinutes)
      ..writeByte(2)
      ..write(obj.snoozeIntervalMinutes)
      ..writeByte(3)
      ..write(obj.kissesPerTask)
      ..writeByte(4)
      ..write(obj.lunchMinutesSinceMidnight)
      ..writeByte(5)
      ..write(obj.dinnerMinutesSinceMidnight)
      ..writeByte(6)
      ..write(obj.dayEndMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
