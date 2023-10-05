import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ipuc/models/slide.dart';

part 'presentation.g.dart'; // Nombre del archivo del adaptador generado

@HiveType(typeId: 23)
class Presentation {
  @HiveField(1)
  final String image;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String preacher;

  @HiveField(5)
  final String topic;

  @HiveField(6)
  final RxList<Slide> slides; // Convertir en RxList<Slide>

  @HiveField(7)
  final String key;

  Presentation({
    required this.key,
    required this.image,
    required this.name,
    required this.date,
    required this.preacher,
    required this.topic,
    required this.slides,
  });
}
