// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slide.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SlideAdapter extends TypeAdapter<Slide> {
  @override
  final int typeId = 24;

  @override
  Slide read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Slide(
      key: fields[0] as String,
      type: fields[1] as String,
      dataType: fields[2] as String,
      dataTypePath: fields[4] as String,
      json: fields[3] as String,
      dataTypeMode: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Slide obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.dataType)
      ..writeByte(3)
      ..write(obj.json)
      ..writeByte(4)
      ..write(obj.dataTypePath)
      ..writeByte(5)
      ..write(obj.dataTypeMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlideAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
