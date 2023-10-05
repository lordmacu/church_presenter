import 'package:diacritic/diacritic.dart';
import 'package:hive/hive.dart';
import 'package:ipuc/core/sqlite_helper.dart';
import 'package:ipuc/models/book.dart';
import 'package:ipuc/models/testament.dart';
import 'package:ipuc/models/verse.dart';

class VerseService {
  Future<List<Map<String, dynamic>>> getAllVersesWithRelations(
      String version) async {
    final db = await DatabaseHelper().db;

    if (db == null) {
      return [];
    }

    final List<Map<String, dynamic>> verses = await db.rawQuery('''
  SELECT verses.*
  FROM verses
  WHERE verses.version = ?
  LIMIT 50
''', [version]);

    return verses;
  }

  Future<List<String>> getAllUniqueVersions() async {
    final db = await DatabaseHelper().db;

    if (db == null) {
      return [];
    }

    final List<Map<String, dynamic>> rows = await db.rawQuery('''
    SELECT DISTINCT version FROM verses
  ''');

    List<String> versions =
        rows.map((row) => row['version'] as String).toList();

    return versions;
  }

  Future<List<Map<String, dynamic>>> searchVerses(
      String searchTerm, String version) async {
    final db = await DatabaseHelper().db;

    if (db == null) {
      return [];
    }

    searchTerm = removeDiacritics(searchTerm.toLowerCase());

    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT *
    FROM verses
    WHERE (LOWER(book_chapter_verse) LIKE ? OR LOWER(searchableText) LIKE ?) AND LOWER(version) = ?
    LIMIT 50
  ''', ['%$searchTerm%', '%$searchTerm%', version.toLowerCase()]);

    return results;
  }

  Future<List<Map<String, dynamic>>> searchVersess(String query) async {
    var verseBox = await Hive.openBox<Verse>('verses');
    var bookBox = await Hive.openBox<Book>('books');
    var testamentBox = await Hive.openBox<Testament>('testaments');

    String cleanQuery = removeDiacritics(query.toLowerCase());

    List<Map<String, dynamic>> result = [];

    List<String> parts = cleanQuery.split(RegExp(r'[:\-\s]'));

    String bookQuery = parts[0];
    int? chapterQuery;
    int? verseQuery;
    bool incompleteVerseQuery = cleanQuery.endsWith('-');

    if (parts.length > 1) {
      chapterQuery = int.tryParse(parts[1]);
    }
    if (parts.length > 2) {
      verseQuery = int.tryParse(parts[2]);
    }

    for (var verse in verseBox.values) {
      var book = bookBox.get(verse.bookId);
      var testament = testamentBox.get(book?.testamentId);

      String cleanBookName = removeDiacritics(book?.name.toLowerCase() ?? '');
      String cleanVerseText = removeDiacritics(verse.text.toLowerCase());

      if (cleanBookName.contains(bookQuery) ||
          cleanVerseText.contains(cleanQuery)) {
        if (chapterQuery == null || chapterQuery == verse.chapter) {
          if (verseQuery == null ||
              verseQuery == verse.verse ||
              incompleteVerseQuery) {
            result.add({
              'verse': verse,
              'book': book,
              'testament': testament,
            });
          }
        }
      }
    }

    verseBox.close();
    bookBox.close();
    testamentBox.close();

    return result;
  }
}
