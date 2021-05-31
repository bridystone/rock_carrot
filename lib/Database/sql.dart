import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

const String globalDbName = 'sandsteinklettern.db';

class SqlHandler {
  /// Singleton instance of the class
  static final SqlHandler _singleton = SqlHandler._internal();

  /// internal db connection - DO NOT USE even internally
  /// use getter database instead
  Future<Database>? _db;

  // hide constructor as private
  SqlHandler._internal();
  // factory constructur of singleton
  factory SqlHandler() {
    return _singleton;
  }

  /// static constants for all tablenames
  static const countriesTablename = 'land';
  static const areasTablename = 'gebiet';
  static const subareasTablename = 'teilgebiet';
  static const rocksTablename = 'gipfel';
  static const routesTablename = 'wege';
  static const commentsTablename = 'komment';

  ///teufelsturm tables
  static const ttRocksTablename = 'tt_rocks';
  static const ttRoutesTablename = 'tt_routes';
  static const ttCommentsTablename = 'tt_comments';

  /// table configuration in database
  static const databaseTableColumns = {
    countriesTablename: {
      'land': 'TEXT PRIMARY KEY',
      'ISO3166': 'TEXT',
      'KFZ': 'TEXT',
    },
    // json query key: land
    areasTablename: {
      'gebiet_ID': 'INT PRIMARY KEY',
      'gebiet': 'TEXT',
      'land': 'TEXT',
      'sprache2': 'TEXT',
      'gdefaultanzeige': 'TEXT',
      'schwskala': 'TEXT',
    },
    // json query key: gebietid
    subareasTablename: {
      'sektor_ID': 'INT PRIMARY KEY',
      'gebietid': 'INT',
      'sektornr': 'TEXT',
      'sektorname_d': 'TEXT',
      'sektorname_cz': 'TEXT',
    },
    // json query key: sektorid
    rocksTablename: {
      'gipfel_ID': 'INT PRIMARY KEY',
      'gipfelnr': 'TEXT',
      'gipfelname_d': 'TEXT',
      'gipfelname_cz': 'TEXT',
      'status': 'TEXT',
      'typ': 'TEXT',
      'vgrd': 'TEXT',
      'ngrd': 'TEXT',
      'posfehler': 'TEXT',
      'schartenhoehe': 'TEXT',
      'talhoehe': 'TEXT',
      'sektorid': 'INT',
    },
    // json query key: sektorid
    routesTablename: {
      'weg_ID': 'INT PRIMARY KEY',
      'gipfelid': 'INT',
      'schwierigkeit': 'TEXT',
      'erstbegvorstieg': 'TEXT',
      'erstbegnachstieg': 'TEXT',
      'erstbegdatum': 'TEXT',
      'ringzahl': 'TEXT',
      'wegbeschr_d': 'TEXT',
      'wegbeschr_cz': 'TEXT',
      'kletterei': 'TEXT',
      'wegname_d': 'TEXT',
      'wegname_cz': 'TEXT',
      'wegstatus': 'TEXT',
      'wegnr': 'TEXT',
    },
    // json query keys: gebietid or sektorid
    commentsTablename: {
      'komment_ID': 'INT PRIMARY KEY',
      'userid': 'INT',
      'datum': 'TEXT',
      'adatum': 'TEXT',
      'wegid': 'INT',
      'sektorid': 'INT',
      'gebietid': 'INT',
      'qual': 'TEXT',
      'sicher': 'TEXT',
      'nass': 'TEXT',
      'kommentar': 'TEXT',
      'gipfelid': 'INT',
      'schwer': 'TEXT',
      'geklettert': 'TEXT',
      'begehung': 'TEXT',
    },
    ttRocksTablename: {
      'id': 'INT PRIMARY KEY', // internal TT number
      'nr': 'TEXT', // number in area
      'name': 'TEXT',
      'areaid': 'INT',
      'areaName': 'TEXT',
    },
    ttRoutesTablename: {
      'id': 'INT PRIMARY KEY', // internal TT number
      'name': 'TEXT',
      'average_quality': 'TEXT',
      'difficulty': 'TEXT',
      // internal TT number (might be missing depending on scraping method)
      'rockid': 'INT',
      'rockName': 'TEXT',
      // internal TT number (might be missing depending on scraping methof)
      'areaid': 'INT',
      'areaName': 'TEXT',
    },
    ttCommentsTablename: {
      'ID': 'INTEGER PRIMARY KEY AUTOINCREMENT',
      'routeid': 'INT',
      'areaid': 'INT',
      'user': 'TEXT',
      'date': 'TEXT',
      'comment': 'TEXT',
      'quality': 'TEXT',
    }
  };

  /// database connection
  ///
  /// will be opened once, if not yet initialized
  Future<Database> get database {
    _db ??= _openConnection(resetDatabase: false);
    return _db!;
  }

  /// open connection to the database
  ///
  /// only to be used from the database getter
  /// checks existance of folder and creates database if necessary
  // TODO: resetDatabase currently not used/usable
  Future<Database> _openConnection({bool resetDatabase = false}) async {
    // TODO: Change back to databasesPath, to ensure correct working
    final databasesPath =
        '/sdcard/Android/data/info.breidenstein.rock_carrot/'; //ONLY FOR TESTING ON Emulator
    //final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, globalDbName);
    // Make sure the directory exists
    try {
      await Directory(databasesPath).create(recursive: true);
      if (resetDatabase) await File(path).delete();
    } catch (e) {
      print('failed to create directory or delete database:' + e.toString());
    }
    //Sqflite.devSetDebugModeOn(true);
    return await openDatabase(
      path,
      // version has to be set (1), otherwise onCreate won't work
      version: 1,
      // create database tables for newly created files
      onCreate: _onCreate,
    );
  }

  /// create tables for a newly created DB file
  FutureOr<void> _onCreate(Database db, dynamic id) {
    print('create Tables' + id.toString());
    databaseTableColumns.forEach((tablename, columns) {
      //generate create string
      var createString = 'CREATE TABLE ' + tablename + '(';
      for (var i = 0; i < columns.keys.length; i++) {
        createString +=
            columns.keys.elementAt(i) + ' ' + columns.values.elementAt(i) + ',';
      }
      createString = createString.substring(0, createString.length - 1) + ')';
      db.execute(createString);
    });
    // create indexes for PRIMARY KEYS & FOREIGN LOOKUPS
    //TODO: is indexes for PRIMARY KEYS necessary?
    db.execute('CREATE INDEX pk_land ON land (land)');

    db.execute('CREATE INDEX pk_gebiet_ID ON gebiet (gebiet_ID)');
    db.execute('CREATE INDEX fk_gebiet_land ON gebiet (land)');

    db.execute('CREATE INDEX pk_sektor_ID ON teilgebiet (sektor_ID)');
    db.execute('CREATE INDEX fk_sektor_gebietid ON teilgebiet (gebietid)');

    db.execute('CREATE INDEX pk_gipfel_ID ON gipfel (gipfel_ID)');
    db.execute('CREATE INDEX fk_gipfel_sektorid ON gipfel (sektorid)');

    db.execute('CREATE INDEX pk_weg_ID ON wege (weg_ID)');
    db.execute('CREATE INDEX fk_weg_gipfelid ON wege (gipfelid)');

    db.execute('CREATE INDEX pk_komment_ID ON komment (komment_ID)');
    // create indexes for comment lookup
    db.execute('CREATE INDEX komment_gebietd ON komment (gebietid)');
    db.execute('CREATE INDEX komment_sektorid ON komment (sektorid)');
    db.execute('CREATE INDEX komment_gipfelid ON komment (gipfelid)');
    db.execute('CREATE INDEX komment_wegid ON komment (wegid)');

    // TT indexes
    // create indexes for comment lookup
    db.execute('CREATE INDEX tt_comments_areaid ON tt_comments (areaid)');
    db.execute('CREATE INDEX tt_comments_route ON tt_comments (routeid)');

    // mapping table for Teufelsturm
    db.execute(
      'CREATE TABLE IF NOT EXISTS mapping_area ('
      ' "tt_areaid" INT PRIMARY KEY,'
      ' "sandstein_areaid" INT'
      ' );'
      ' INSERT INTO mapping_area VALUES(10, 123)' //	Affensteine '
      ' INSERT INTO mapping_area VALUES(2, 124);' //	Bielatal '
      ' INSERT INTO mapping_area VALUES(11, 125);' //	Erzgebirgsgrenzgebiet '
      ' INSERT INTO mapping_area VALUES(9, 126);' //	Großer Zschand '
      ' INSERT INTO mapping_area VALUES(13, 127);' //	Hinterhermsdorf '
      ' INSERT INTO mapping_area VALUES(7, 128);' //	Brand '
      ' INSERT INTO mapping_area VALUES(8, 129);' //	Kleiner Zschand '
      ' INSERT INTO mapping_area VALUES(5, 130);' //	Rathen '
      ' INSERT INTO mapping_area VALUES(4, 131);' //	Schmilka '
      ' INSERT INTO mapping_area VALUES(3, 132);' //	Schrammsteine '
      ' INSERT INTO mapping_area VALUES(1, 133);' //	Gebiet der Steine'
      ' INSERT INTO mapping_area VALUES(6, 134);' //	Wehlen'
      ' INSERT INTO mapping_area VALUES(12, 135);', //	Wildensteiner Gebiet'
    );
  }

  /// insert all items from retreived json data into datbase
  Future<int> insertJsonData(
      String tablename, Future<List<dynamic>> jsonData) async {
    var rowCount = 0;
    await jsonData.then((finalJsonData) async {
      final db = await SqlHandler().database;
      // starting a batch job
      var batch = db.batch();
      finalJsonData.forEach((dynamic jsonRow) {
        // insert data into database
        batch.insert(
          tablename,
          jsonRow,
        );
        rowCount++;
      });
      // committing the batch
      await batch.commit(noResult: true);
    });
    return rowCount;
  }

  // INSERT INTO DIFFERENT FUNCTION (for SMALL PORTIONS)
  Future<Batch> prepareInsertJsonData() async {
    final db = await SqlHandler().database;
    // starting a batch job
    return db.batch();
  }

  Future<int> enqueueInsertJsonData(
    Batch batch,
    String tablename,
    Future<List<dynamic>> jsonData,
  ) async {
    var rowCount = 0;
    await jsonData.then((finalJsonData) async {
      // starting a batch job
      finalJsonData.forEach((dynamic jsonRow) {
        // insert data into database
        batch.insert(
          tablename,
          jsonRow,
        );
        rowCount++;
      });
    });
    return rowCount;
  }

  Future<List<Object?>> commitInsertJsonData(Batch batch) async {
    return batch.commit();
  }

  /// Inserts a Country row into the database
  FutureOr<int> insertDataFromJson(
      String tableName, Map<String, dynamic> jsonData) {
    return database.then((db) => db.insert(tableName, jsonData));
  }
}
