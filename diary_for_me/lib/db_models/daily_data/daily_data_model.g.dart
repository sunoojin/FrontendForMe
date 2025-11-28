// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppNotificationAdapter extends TypeAdapter<AppNotification> {
  @override
  final int typeId = 0;

  @override
  AppNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppNotification(
      appname: fields[0] as String,
      text: fields[1] as String,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AppNotification obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.appname)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationAdapter extends TypeAdapter<Location> {
  @override
  final int typeId = 1;

  @override
  Location read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Location(
      lat: fields[0] as double,
      lng: fields[1] as double,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Location obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lng)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyDataAdapter extends TypeAdapter<DailyData> {
  @override
  final int typeId = 3;

  @override
  DailyData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyData(
      gallery: (fields[0] as List).cast<String>(),
      location: (fields[1] as List).cast<Location>(),
      appnoti: (fields[2] as List).cast<AppNotification>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.gallery)
      ..writeByte(1)
      ..write(obj.location)
      ..writeByte(2)
      ..write(obj.appnoti);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
