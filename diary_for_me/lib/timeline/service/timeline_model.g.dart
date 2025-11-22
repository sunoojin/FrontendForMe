// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeLineAdapter extends TypeAdapter<TimeLine> {
  @override
  final int typeId = 3;

  @override
  TimeLine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeLine(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      events: (fields[3] as List).cast<Event>(),
      selfsurvey: (fields[4] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TimeLine obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.events)
      ..writeByte(4)
      ..write(obj.selfsurvey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeLineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
