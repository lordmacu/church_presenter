import 'package:hive/hive.dart';

part 'testament.g.dart'; // Nombre del archivo del adaptador generado

// Para Testament
@HiveType(typeId: 26)
class Testament {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  Testament({
    required this.id,
    required this.name,
  });

  factory Testament.fromMap(Map<dynamic, dynamic> map) {
    return Testament(
      id: map['id'],
      name: map['name'],
    );
  }
}
