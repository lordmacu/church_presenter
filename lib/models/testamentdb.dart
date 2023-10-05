class TestamentDb {
  final int? id;
  final String name;

  TestamentDb({this.id, required this.name});

  factory TestamentDb.fromMap(Map<String, dynamic> map) {
    return TestamentDb(id: map['id'], name: map['name']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
