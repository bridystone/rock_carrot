import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

const String globalDbName = "sandsteinklettern.db";

class SqlYacGuideFlutter {
  static final SqlYacGuideFlutter _singleton = SqlYacGuideFlutter._internal();
  static bool _isInitialized = false;
  late final Future<Database> _db;

  // hide constructor as private
  SqlYacGuideFlutter._internal();
  // factory constructur of singleton
  factory SqlYacGuideFlutter() {
    return _singleton;
  }

  Future<Database> get database async {
    if (!_isInitialized) {
      _db = _openConnection(false);
      _isInitialized = true;
    }
    return _db;
  }

  Future<Database> _openConnection(bool resetDatabase) async {
    final databasesPath =
        await getDatabasesPath(); //getApplicationDocumentDirectory()
    print(databasesPath.toString());
    final path = join(databasesPath, globalDbName);
    // Make sure the directory exists
    try {
      await Directory(databasesPath).create(recursive: true);
      if (resetDatabase) File(path).delete();
    } catch (_) {
      print("failed");
    }
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /* 
    Tables created for empty new database
  */
  FutureOr<void> _onCreate(Database db, id) async {
    print("create Tables");
    db.execute(
        "CREATE TABLE land (land TEXT PRIMARY KEY, ISO3166 TEXT, KFZ TEXT)");
    db.execute(
        "CREATE TABLE gebiet (gebiet_ID INT PRIMARY KEY, gebiet TEXT, land TEXT, sprache2 TEXT, gdefaultanzeige TEXT, schwskala TEXT)");
  }

  /* 
    country stuff
  */
  FutureOr<int> deleteCountries() async {
    return database.then((db) => db.delete('land'));
  }

  FutureOr<int> insertCountry(
    String country,
    String iso,
    String kfz,
  ) async {
    return database.then((db) => db.insert(
          'land',
          {
            'land': country,
            'ISO3166': iso,
            'kfz': kfz,
          },
        ));
  }

  Future<List<Map<String, Object?>>> queryCountries() async {
    return database.then((db) => db.query(
          'land',
          columns: ['land'],
        ));
  }

  /*
    area stuff
    */
  FutureOr<int> deleteAreas(String land) async {
    return database.then(
      (db) => db.delete(
        'gebiet',
        where: "land = ?",
        whereArgs: [land],
      ),
    );
  }

  FutureOr<int> insertAreas(
    int gebietID,
    String gebiet,
    String land,
    String sprache2,
    String gdefaultanzeige,
    String schwskala,
  ) async {
    return database.then((db) => db.insert(
          'gebiet',
          {
            'gebiet_ID': gebietID,
            'gebiet': gebiet,
            'land': land,
            'sprache2': land,
            'gdefaultanzeige': land,
            'schwskala': land,
          },
        ));
  }

  Future<List<Map<String, Object?>>> queryAreas(String land) async {
    return database.then((db) => db.query(
          'gebiet',
          columns: ['gebiet', 'land'],
          where: "land = ?",
          whereArgs: [land],
        ));
  }
}
