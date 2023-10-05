class BookDb {
  final int? id;
  final String testamentId;
  final String name;
  final String abbrevation;

  BookDb(
      {this.id,
      required this.testamentId,
      required this.name,
      required this.abbrevation});

  // Convertir un Map a un objeto Song
  factory BookDb.fromMap(Map<String, dynamic> map) {
    return BookDb(
        id: map['id'],
        testamentId: map['testament_id'],
        name: map['name'],
        abbrevation: map["abbrevation"]);
  }

  // Convertir un objeto Song a un Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testamentId': testamentId,
      'name': name,
      'abbrevation': abbrevation
    };
  }
}
