import 'dart:io';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/services.dart';
import 'package:ipuc/core/sqlite_helper.dart';
import 'package:ipuc/models/book.dart';
import 'package:ipuc/models/testament.dart';
import 'package:ipuc/models/verse.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class BibleService {
  var rtfwords = [
    "rtf",
    "ansi",
    "mac",
    "pc",
    "pca",
    "ansicpg",
    "deff",
    "deflang",
    "deflangfe",
    "adeflang",
    "adeflangfe",
    "paperw",
    "paperh",
    "margl",
    "margr",
    "margt",
    "margb",
    "landscape",
    "portrait",
    "sectd",
    "titlepg",
    "facingp",
    "rtlgutter",
    "viewkind",
    "vieww",
    "viewh",
    "viewscale",
    "pgnstart",
    "pgnrestart",
    "pgncont",
    "pgnx",
    "pgny",
    "pgnh",
    "pgwsxn",
    "pghsxn",
    "marglsxn",
    "margrsxn",
    "margtsxn",
    "margbsxn",
    "guttersxn",
    "f",
    "fs",
    "fnil",
    "froman",
    "fswiss",
    "fmodern",
    "fscript",
    "fdecor",
    "ftech",
    "fbidi",
    "fcharset",
    "cf",
    "cb",
    "cpg",
    "expnd",
    "expndtw",
    "kerning",
    "b",
    "i",
    "ul",
    "ulnone",
    "ulw",
    "uld",
    "uldb",
    "ulth",
    "ulthd",
    "ulthdash",
    "ulthdashd",
    "ulthdashdd",
    "strike",
    "sub",
    "super",
    "nosupersub",
    "scaps",
    "outl",
    "shad",
    "v",
    "fsxx",
    "dn",
    "highlight",
    "uldash",
    "uldashd",
    "uldashdd",
    "ulwave",
    "ulhwave",
    "ululdbwave",
    "plain",
    "embo",
    "caps",
    "nospace",
    "lang",
    "langfe",
    "langnp",
    "langfenp",
    "noproof",
    "stshdbch",
    "stshfloch",
    "stshfhich",
    "stshfbi",
    "par",
    "pard",
    "li",
    "fi",
    "ri",
    "rin",
    "line",
    "ql",
    "qr",
    "qj",
    "qc",
    "sb",
    "sa",
    "sbk",
    "pagebb",
    "sl",
    "slmult",
    "pararsid",
    "linex",
    "brdrb",
    "brdrs",
    "brdrl",
    "brdrt",
    "brsp",
    "tx",
    "ltrpar",
    "rtlpar",
    "ab",
    "absh",
    "dcs",
    "faauto",
    "fahang",
    "favar",
    "fj",
    "adjustright",
    "keep",
    "keepn",
    "level",
    "nosnap",
    "nowwrap",
    "shading",
    "sect",
    "sbknone",
    "sbkcol",
    "sbkpage",
    "pgnstart",
    "pgnrestart",
    "pgncont",
    "pgnx",
    "pgny",
    "pgnh",
    "pgwsxn",
    "pghsxn",
    "marglsxn",
    "margrsxn",
    "margtsxn",
    "margbsxn",
    "guttersxn",
    "ltrsect",
    "rtlsect",
    "sectunlocked",
    "sectd",
    "linemod",
    "linex",
    "line",
    "linecont",
    "linestart",
    "linerestart",
    "linestarts",
    "linerestarts",
    "linetts",
    "linettm",
    "lineppage",
    "linebpage",
    "trowd",
    "cell",
    "row",
    "intbl",
    "irow",
    "irowband",
    "trql",
    "trqr",
    "trqc",
    "trrh",
    "trleft",
    "cellx",
    "clmgf",
    "clmrg",
    "clvmgf",
    "clvmrg",
    "clvertalt",
    "clvertalc",
    "clvertalb",
    "cltxlrtb",
    "cltxbtlr",
    "cltxtbrl",
    "cltxlrtbv",
    "cltxtbrlv",
    "trbrdrb",
    "trbrdrl",
    "trbrdrr",
    "trbrdrt",
    "clbrdrb",
    "clbrdrl",
    "clbrdrr",
    "clbrdrt",
    "brdrtbl",
    "brdrnil",
    "clpadl",
    "clpadt",
    "clpadr",
    "clpadb",
    "cellpaddl",
    "cellpaddt",
    "cellpaddr",
    "cellpadb",
    "clshdng",
    "clcfpat",
    "clcbpat",
    "ls",
    "li",
    "fi",
    "pn",
    "pnlvl",
    "ilvl",
    "listtext",
    "list",
    "listtable",
    "listname",
    "listid",
    "listoverride",
    "listoverridetable",
    "pnstart",
    "pnindent",
    "pndec",
    "pnlcltr",
    "pnlcrm",
    "pnf",
    "pni",
    "pnstrike",
    "pncf",
    "pnseclvl",
    "pnrauth",
    "pnrdate",
    "pnrnot",
    "pnrrgb",
    "pnrpnbrk",
    "colortbl",
    "red",
    "green",
    "blue",
    "tab",
    "lquote",
    "rquote",
    "ldblquote",
    "rdblquote",
    "emdash",
    "endash",
    "bullet",
    "~",
    "lbr",
    "rbr",
    "zwbo",
    "zwj",
    "zwnbo",
    "zwnj",
    "object",
    "pict",
    "shp",
    "shptxt",
    "shprslt",
    "shpz",
    "sp",
    "sn",
    "sv",
    "objemb",
    "objlink",
    "objautlink",
    "objsub",
    "objpub",
    "objicemb",
    "objhtml",
    "objocx",
    "u",
    "uc",
    "ucl",
    "ud",
    "info",
    "author",
    "creatim",
    "revtim",
    "version",
    "vern",
    "edmins",
    "nofpages",
    "nofwords",
    "nofchars",
    "nofcharsws",
    "id",
    "operator",
    "category",
    "manager",
    "company",
    "doccomm",
    "hlinkbase",
    "title",
    "subject",
    "keywords",
    "comment",
    "vern",
    "docnofastaves",
    "*",
    "\\",
    "{",
    "}",
    "nonesttables",
    "nesttableprops",
    "nestrow",
    "nestcell",
    "row",
    "cell",
    "intbl",
    "nest",
    "nonesttables",
    "shpinst",
    "shpgrp",
    "shpwr",
    "shpfhdr",
    "xe",
    "tc",
    "txe",
    "bkmkstart",
    "bkmkend",
    "field",
    "fldinst",
    "fldrslt",
    "datafield",
    "formfield",
    "formfield",
    "ffname",
    "ffdeftext",
    "ffformat",
    "ffhelptext",
    "ffstattext"
  ];
  String removeRtfKeywords(String inputText, List<String> keywords) {
    String cleanedText = inputText;

    for (String keyword in keywords) {
      // Escapar caracteres especiales en la palabra clave
      String escapedKeyword = RegExp.escape(keyword);

      // Crear la expresión regular
      RegExp regExp = RegExp(r"\\(" + escapedKeyword + r")([^\s\\{}]*|\s?)");

      // Reemplazar en el texto
      cleanedText = cleanedText.replaceAll(regExp, '');
    }

    // Convertir secuencias especiales a sus caracteres Unicode equivalentes
    cleanedText = cleanedText.replaceAll(r"\'e1", "á");
    cleanedText = cleanedText.replaceAll(r"\'e9", "é");
    cleanedText = cleanedText.replaceAll(r"\'ed", "í");
    cleanedText = cleanedText.replaceAll(r"\'f3", "ó");
    cleanedText = cleanedText.replaceAll(r"\'fa", "ú");
    cleanedText = cleanedText.replaceAll(r"\'fc", "ü"); // Añadido
    cleanedText = cleanedText.replaceAll(r"\'c1", "Á");
    cleanedText = cleanedText.replaceAll(r"\'c9", "É");
    cleanedText = cleanedText.replaceAll(r"\'cd", "Í");
    cleanedText = cleanedText.replaceAll(r"\'d3", "Ó");
    cleanedText = cleanedText.replaceAll(r"\'da", "Ú");
    cleanedText = cleanedText.replaceAll(r"\'bf", "¿");
    cleanedText = cleanedText.replaceAll(r"\'f1", "ñ");
    cleanedText = cleanedText.replaceAll(r"\'d1", "Ñ");
    cleanedText = cleanedText.replaceAll(r"\'a1", "¡");
    cleanedText = cleanedText.replaceAll(r"\'ab", "«");
    cleanedText = cleanedText.replaceAll(r"\'bb", "»");

    // Eliminar anotaciones como { [a]}, { [b]} etc.
    cleanedText =
        cleanedText.replaceAll(RegExp(r'\{\s?\[[a-zA-Z0-9]+\]\}'), '');

    // Añadir más reemplazos según sea necesario

    return cleanedText;
  }

  Future<void> initVerses() async {
    await initializeDatabase("rvr1960");
    await initializeDatabase("NTVivi");
    await initializeDatabase("NVI1999");
    await initializeDatabase("RVC");
    await initializeDatabase("PDT8");
    await initializeDatabase("bad");
    await initializeDatabase("BLSee");
  }

  Future<void> initializeDatabase(version) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "${version}.db");

    ByteData data =
        await rootBundle.load(join("lib/assets/bibles/${version}.sqlite"));
    List<int> bytes = data.buffer.asUint8List();
    await File(path).writeAsBytes(bytes);

    Database db = await openDatabase(path);

    // Obtén la instancia de la base de datos ipuc.db usando el helper
    final ipucDb = await DatabaseHelper().db;

    if (ipucDb == null) {
      return;
    }
    Map<String, String> bookTextMap = {};

    // Importar libros
    final List<Map<String, dynamic>> books = await db.query('book');
    for (var book in books) {
      Map<String, dynamic> bookCopy = {};

      // Modificar la copia
      bookCopy["book_id"] = book["id"];
      bookCopy["testament_id"] = book["testament_id"];
      bookCopy["name"] = book["name"];
      bookCopy["abbreviation"] = book["abbreviation"];
      bookTextMap[book["id"].toString()] = book["name"].toString();

      await ipucDb.insert('books', bookCopy);
    }

    // Importar testamentos
    final List<Map<String, dynamic>> testaments = await db.query('testament');
    for (var testament in testaments) {
      Map<String, dynamic> testamentCopy = {};

      // Modificar la copia
      testamentCopy["testament_id"] = testament["id"];
      testamentCopy["name"] = testament["book_id"];

      await ipucDb.insert('testaments', testamentCopy);
    }

    final List<Map<String, dynamic>> verses = await db.query('verse');
    for (var verse in verses) {
      // Hacer una copia superficial del mapa 'verse' para poder modificarlo
      Map<String, dynamic> verseCopy = {};

      String bookName = bookTextMap[verse["book_id"].toString()] ?? 'Unknown';
      // Asumiendo que "book_id" contiene el nombre del libro

      // Combinaciones
      List<String> combinations = [
        "$bookName ${verse["chapter"]} ${verse["verse"]}",
        "$bookName ${verse["chapter"]}:${verse["verse"]}",
        "$bookName ${verse["chapter"]}-${verse["verse"]}",
        "$bookName ${verse["chapter"]}.${verse["verse"]}",
        removeDiacritics("$bookName ${verse["chapter"]} ${verse["verse"]}"),
        removeDiacritics("$bookName ${verse["chapter"]}:${verse["verse"]}"),
        removeDiacritics("$bookName ${verse["chapter"]}-${verse["verse"]}"),
        removeDiacritics("$bookName ${verse["chapter"]}.${verse["verse"]}")
      ].map((str) => str.toLowerCase()).toList(); // Convertir a minúsculas
      String allCombinations = combinations.join(" ");

      var cleanText = removeRtfKeywords(verse["text"], rtfwords);
      // Modificar la copia
      verseCopy["verse_id"] = verse["id"];
      verseCopy["book_id"] = verse["book_id"];
      verseCopy["book_name"] = verse["book_name"];
      verseCopy["book_text"] = bookName; // Aquí se incluye el texto del libro
      verseCopy["version"] = version;
      verseCopy["chapter"] = verse["chapter"];
      verseCopy["verse"] = verse["verse"];
      verseCopy["book_chapter_verse"] = allCombinations;
      verseCopy["text"] = cleanText;
      verseCopy["searchableText"] = removeDiacritics(cleanText);

      print("original : ${verse["text"]} modificado : ${cleanText}");

      await ipucDb.insert('verses', verseCopy);
    }

    // Cierra la base de datos de la biblia cuando hayas terminado
    //await db.close();
    //await ipucDb.close();
  }

  Future<void> initializeDatabases(version) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "${version}.db");

    ByteData data =
        await rootBundle.load(join("lib/assets/bibles/${version}.sqlite"));
    List<int> bytes = data.buffer.asUint8List();
    await File(path).writeAsBytes(bytes);

    Database db = await openDatabase(path);

    await Hive.initFlutter();

    var bookBox = await Hive.openBox('books');
    var testamentBox = await Hive.openBox('testaments');
    var verseBox = await Hive.openBox('verses');

    List<Map> books = await db.query('book');
    for (var item in books) {
      Book book = Book.fromMap(item);
      await bookBox.add(book);
    }

    List<Map> testaments = await db.query('testament');
    for (var item in testaments) {
      Testament testament = Testament.fromMap(item);
      await testamentBox.add(testament);
    }

    List<Map> verses = await db.query('verse');
    for (var item in verses) {
      var itemMod = Map<String, dynamic>.from(item);
      itemMod["version"] = 'rvr1960';
      Verse verse = Verse.fromMap(itemMod);
      await verseBox.add(verse);
    }

    await bookBox.close();

    await testamentBox.close();

    await verseBox.close();
  }
}
