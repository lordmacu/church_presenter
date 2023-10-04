// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paragraph.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParagraphAdapter extends TypeAdapter<Paragraph> {
  @override
  final int typeId = 22;

  @override
  Paragraph read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Paragraph(
      lines: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Paragraph obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.lines);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParagraphAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
