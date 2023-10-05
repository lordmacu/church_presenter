import 'package:hive/hive.dart';

part 'slide.g.dart'; // Nombre del archivo del adaptador generado

@HiveType(typeId: 24)
class Slide {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String dataType;

  @HiveField(3)
  final String json;

  @HiveField(4)
  final String dataTypePath;
  @HiveField(5)
  final String dataTypeMode;

  Slide({
    required this.key,
    required this.type,
    required this.dataType,
    required this.dataTypePath,
    required this.json,
    required this.dataTypeMode,
  });
}
