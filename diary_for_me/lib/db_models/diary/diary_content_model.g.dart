// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_content_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaryContentAdapter extends TypeAdapter<DiaryContent> {
  @override
  final int typeId = 10;

  @override
  DiaryContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiaryContent(
      text: fields[0] as String,
      image: (fields[1] as List).cast<String>(),
      music: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DiaryContent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.music);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
