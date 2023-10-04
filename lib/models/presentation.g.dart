// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresentationAdapter extends TypeAdapter<Presentation> {
  @override
  final int typeId = 23;

  @override
  Presentation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Presentation(
      key: fields[7] as String,
      image: fields[1] as String,
      name: fields[2] as String,
      date: fields[3] as DateTime,
      preacher: fields[4] as String,
      topic: fields[5] as String,
      slides: (fields[6] as List).cast<Slide>().obs,
    );
  }

  @override
  void write(BinaryWriter writer, Presentation obj) {
    writer
      ..writeByte(7)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.preacher)
      ..writeByte(5)
      ..write(obj.topic)
      ..writeByte(6)
      ..write(obj.slides)
      ..writeByte(7)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresentationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
