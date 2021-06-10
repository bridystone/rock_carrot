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

  /// teufelsturm to sandstein mapping tables
  static const ttMappingAreasTablename = 'tt_mapping_areas';
  static const ttMappingRocksTablename = 'tt_mapping_rocks';
  static const ttMappingRoutesTablename = 'tt_mapping_routes';

  /// constant mapping tables to map rocks/routes staticly
  static const ttMappingRocksStaticTablename = 'tt_mapping_rocks_static';
  static const ttMappingRoutesStaticTablename = 'tt_mapping_routes_static';

  /// table configuration in database
  static const databaseTableColumns = {
    countriesTablename: {
      'land': 'TEXT COLLATE NOCASE PRIMARY KEY',
      'ISO3166': 'TEXT COLLATE NOCASE',
      'KFZ': 'TEXT COLLATE NOCASE',
    },
    // json query key: land
    areasTablename: {
      'gebiet_ID': 'INT PRIMARY KEY',
      'gebiet': 'TEXT COLLATE NOCASE',
      'land': 'TEXT COLLATE NOCASE',
      'sprache2': 'TEXT COLLATE NOCASE',
      'gdefaultanzeige': 'TEXT COLLATE NOCASE',
      'schwskala': 'TEXT COLLATE NOCASE',
    },
    // json query key: gebietid
    subareasTablename: {
      'sektor_ID': 'INT PRIMARY KEY',
      'gebietid': 'INT',
      'sektornr': 'TEXT COLLATE NOCASE',
      'sektorname_d': 'TEXT COLLATE NOCASE',
      'sektorname_cz': 'TEXT COLLATE NOCASE',
    },
    // json query key: sektorid
    rocksTablename: {
      'gipfel_ID': 'INT PRIMARY KEY',
      'gipfelnr': 'TEXT COLLATE NOCASE',
      'gipfelname_d': 'TEXT COLLATE NOCASE',
      'gipfelname_cz': 'TEXT COLLATE NOCASE',
      'status': 'TEXT COLLATE NOCASE',
      'typ': 'TEXT COLLATE NOCASE',
      'vgrd': 'TEXT COLLATE NOCASE',
      'ngrd': 'TEXT COLLATE NOCASE',
      'posfehler': 'TEXT COLLATE NOCASE',
      'schartenhoehe': 'TEXT COLLATE NOCASE',
      'talhoehe': 'TEXT COLLATE NOCASE',
      'sektorid': 'INT',
    },
    // json query key: sektorid
    routesTablename: {
      'weg_ID': 'INT PRIMARY KEY',
      'gipfelid': 'INT',
      'schwierigkeit': 'TEXT COLLATE NOCASE',
      'erstbegvorstieg': 'TEXT COLLATE NOCASE',
      'erstbegnachstieg': 'TEXT COLLATE NOCASE',
      'erstbegdatum': 'TEXT COLLATE NOCASE',
      'ringzahl': 'TEXT COLLATE NOCASE',
      'wegbeschr_d': 'TEXT COLLATE NOCASE',
      'wegbeschr_cz': 'TEXT COLLATE NOCASE',
      'kletterei': 'TEXT COLLATE NOCASE',
      'wegname_d': 'TEXT COLLATE NOCASE',
      'wegname_cz': 'TEXT COLLATE NOCASE',
      'wegstatus': 'TEXT COLLATE NOCASE',
      'wegnr': 'TEXT COLLATE NOCASE',
    },
    // json query keys: gebietid or sektorid
    commentsTablename: {
      'komment_ID': 'INT PRIMARY KEY',
      'userid': 'INT',
      'datum': 'TEXT COLLATE NOCASE',
      'adatum': 'TEXT COLLATE NOCASE',
      'wegid': 'INT',
      'sektorid': 'INT',
      'gebietid': 'INT',
      'qual': 'TEXT COLLATE NOCASE',
      'sicher': 'TEXT COLLATE NOCASE',
      'nass': 'TEXT COLLATE NOCASE',
      'kommentar': 'TEXT COLLATE NOCASE',
      'gipfelid': 'INT',
      'schwer': 'TEXT COLLATE NOCASE',
      'geklettert': 'TEXT COLLATE NOCASE',
      'begehung': 'TEXT COLLATE NOCASE',
    },

    /// Teufelsturm data tables
    ttRocksTablename: {
      'id': 'INT PRIMARY KEY', // internal TT number
      'nr': 'TEXT COLLATE NOCASE', // number in area
      'name': 'TEXT COLLATE NOCASE',
      'areaid': 'INT',
      'areaName': 'TEXT COLLATE NOCASE',
    },
    ttRoutesTablename: {
      'id': 'INT PRIMARY KEY', // internal TT number
      'name': 'TEXT COLLATE NOCASE',
      'average_quality': 'TEXT COLLATE NOCASE',
      'difficulty': 'TEXT COLLATE NOCASE',
      // internal TT number (might be missing depending on scraping method)
      'rockid': 'INT',
      'rockName': 'TEXT COLLATE NOCASE',
      // internal TT number (might be missing depending on scraping methof)
      'areaid': 'INT',
      'areaName': 'TEXT COLLATE NOCASE',
    },
    ttCommentsTablename: {
      'ID': 'INTEGER PRIMARY KEY AUTOINCREMENT',
      'routeid': 'INT',
      // internal TT number (might be missing depending on scraping method)
      'rockid': 'INT',
      'areaid': 'INT',
      'user': 'TEXT COLLATE NOCASE',
      'date': 'TEXT COLLATE NOCASE',
      'comment': 'TEXT COLLATE NOCASE',
      'quality': 'TEXT COLLATE NOCASE',
    },

    /// teufelsturm mapping tables
    ttMappingAreasTablename: {
      'tt_areaid': 'INT PRIMARY KEY',
      'sandstein_areaid': 'INT',
    },
    ttMappingRocksTablename: {
      'tt_rockid': 'INT PRIMARY KEY',
      'sandstein_rockid': 'INT',
      'tt_areaid': 'INT',
    },
    ttMappingRoutesTablename: {
      'tt_routeid': 'INT PRIMARY KEY',
      'sandstein_routeid': 'INT',
      'tt_areaid': 'INT',
    },
    ttMappingRocksStaticTablename: {
      'tt_rockname': 'TEXT NOT NULL COLLATE NOCASE',
      'sandstein_rockname': 'TEXT NOT NULL COLLATE NOCASE PRIMARY KEY',
    },
    ttMappingRoutesStaticTablename: {
      'tt_routename': 'TEXT NOT NULL COLLATE NOCASE',
      'sandstein_routename': 'TEXT NOT NULL COLLATE NOCASE PRIMARY KEY',
    },
  };

  /// database connection
  ///
  /// will be opened once, if not yet initialized
  Future<Database> get database {
    _db ??= _openConnection();
    return _db!;
  }

  /// open connection to the database
  ///
  /// only to be used from the database getter
  /// checks existance of folder and creates database if necessary
  Future<Database> _openConnection() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, globalDbName);
    print(path);
    // Make sure the directory exists
    try {
      await Directory(databasesPath).create(recursive: true);
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

    /// TT mapping table indexes
    db.execute(
      'CREATE INDEX idx_tt_mapping_areas_sandstein ON tt_mapping_areas (sandstein_areaid)',
    );
    db.execute(
      'CREATE INDEX idx_tt_mapping_rocks_sandstein ON tt_mapping_rocks (sandstein_rockid)',
    );
    db.execute(
      'CREATE INDEX idx_tt_mapping_routes_sandstein ON tt_mapping_routes (sandstein_routeid)',
    );

    // mapping between TT and sandsteinklettern
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (10,123)'); // Affensteine
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (2,124)'); //	Bielatal
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (11,125)'); //	Erzgebirgsgrenzgebiet
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (9,126)'); //	Großer Zschand
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (13,127)'); //	Hinterhermsdorf
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (7,128)'); //	Brand
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (8,129)'); //	Kleiner Zschand
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (5,130)'); //	Rathen
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (4,131)'); //	Schmilka
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (3,132)'); //	Schrammsteine
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (1,133)'); //	Gebiet der Steine
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (6,134)'); //	Wehlen
    db.execute(
        'INSERT INTO tt_mapping_areas (tt_areaid, sandstein_areaid) VALUES (12,135)'); //	Wildensteiner Gebiet

    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Pascher (Dreifreundeturm)\', \'Pascher\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Gemeinschaftsturm (Einsamer Turm)\', \'Gemeinschaftsturm\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Keule (Osterspitze)\', \'Keule\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Rabensteinturm (Ameisenturm)\', \'Rabensteinturm\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Rätselturm (Späte Zinne)\', \'Rätselturm\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Hexe (Hänsel)\', \'Hexe\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Lößnitzturm (Brandriff)\', \'Lößnitzturm\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Meilerstein (Stumpfes Horn)\', \'Meilerstein\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Tarzan (Rotweinspitze)\', \'Tarzan\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Pilzwand (Pilzturm)\', \'Pilzwand\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Panoramascheibe (Rauensteinscheibe)\', \'Panoramascheibe\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Dornröschen (Kapellenwand)\', \'Dornröschen\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Waldschrat\', \'Waldschratt\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Großer Felsenbrückenturm\', \'Felsenbrückenturm\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Liebespaar, Südturm\', \'Südturm Liebespaar\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Liebespaar, Nordturm\', \'Nordturm Liebespaar\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Gralsburg, Nordostzinne\', \'NO-Zinne Gralsburg\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Gralsburg, Südwestzinne\', \'SW-Zinne Gralsburg\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Friedensturm (Pilzturm)\', \'Pilzturm\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'1. Zerborstener Turm\', \'Erster Zerborstener Turm\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'2. Zerborstener Turm\', \'Zweiter Zerborstener Turm\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Festung Königstein\', \'Königstein\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Lilienstein - Westecke\', \'Lilienstein-Westecke\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Pfaffenkopf (Buchfinkenturm)\', \'Buchfinkenturm\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Zwergfels\', \'Zwerg\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Fünf Gipfel, Südturm\', \'Südturm Fünf Gipfel\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Fünf Gipfel, Nordwestturm\', \'Nordwestturm Fünf Gipfel\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Fünf Gipfel, Nordostturm\', \'Nordostturm Fünf Gipfel\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Siamesische Zwillinge, Doof\', \'Doof Siamesische Zwillinge\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Siamesische Zwillinge, Dick\', \'Dick Siamesische Zwillinge\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Lokomotive-Esse\', \'Lokomotive - Esse\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Burgenerturm\', \'Burgener Turm\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Litfasssäule\', \'Litfaßsäule\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Amboss\', \'Amboß\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Kleiner Amboss\', \'Kleiner Amboß\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Bloßstock\', \'Bloszstock\')');
    db.execute(
        'INSERT INTO tt_mapping_rocks_static (sandstein_rockname, tt_rockname) VALUES(\'Kleingießhübeler Turm\', \'Kleingießhübler Turm\')');

    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'Alter Weg\', \'AW\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'Alter Weg direkt\', \'AW direkt\')');

    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordweg\', \'N-Weg\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordostweg\', \'NO-Weg\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'ostweg\', \'O-Weg\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südostweg\', \'SO-Weg\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südweg\', \'S-Weg\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südwestweg\', \'SW-Weg\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'westweg\', \'W-Weg\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordwestweg\', \'NW-Weg\')');

    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordwand\', \'N-wand\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordostwand\', \'NO-wand\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'ostwand\', \'O-wand\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südostwand\', \'SO-wand\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südwand\', \'S-wand\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südwestwand\', \'SW-wand\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'westwand\', \'W-wand\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordwestwand\', \'NW-wand\')');

    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordkante\', \'N-kante\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordostkante\', \'NO-kante\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'ostkante\', \'O-kante\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südostkante\', \'SO-kante\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südkante\', \'S-kante\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südwestkante\', \'SW-kante\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'westkante\', \'W-kante\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordwestkante\', \'NW-kante\')');

    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordkamin\', \'N-kamin\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordostkamin\', \'NO-kamin\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'ostkamin\', \'O-kamin\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südostkamin\', \'SO-kamin\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südkamin\', \'S-kamin\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'südwestkamin\', \'SW-kamin\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'westkamin\', \'W-kamin\')');
    db.execute(
        'INSERT INTO tt_mapping_routes_static (sandstein_routename, tt_routename) VALUES(\'nordwestkamin\', \'NW-kamin\')');
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
