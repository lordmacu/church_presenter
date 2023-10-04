// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_explanation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoExplanationAdapter extends TypeAdapter<VideoExplanation> {
  @override
  final int typeId = 28;

  @override
  VideoExplanation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoExplanation(
      explanations: (fields[0] as List).cast<Paragraph>(),
    );
  }

  @override
  void write(BinaryWriter writer, VideoExplanation obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.explanations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoExplanationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
