import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:ipuc/core/sqlite_helper.dart';

class TestamentDb {
  final int? id;
  final String name;

  TestamentDb({this.id, required this.name});

  // Convertir un Map a un objeto Song
  factory TestamentDb.fromMap(Map<String, dynamic> map) {
    return TestamentDb(id: map['id'], name: map['name']);
  }

  // Convertir un objeto Song a un Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
