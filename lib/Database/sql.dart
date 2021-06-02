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

    /// Teufelsturm data tables
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
      // internal TT number (might be missing depending on scraping method)
      'rockid': 'INT',
      'areaid': 'INT',
      'user': 'TEXT',
      'date': 'TEXT',
      'comment': 'TEXT',
      'quality': 'TEXT',
    },

    /// teufelsturm mapping tables
    ttMappingAreasTablename: {
      'tt_areaid': 'INT PRIMARY KEY',
      'sandstein_areaid': 'INT',
    },
    ttMappingRocksTablename: {
      'tt_rockid': 'INT PRIMARY KEY',
      'sandstein_rockid': 'INT',
    },
    ttMappingRoutesTablename: {
      'tt_routeid': 'INT PRIMARY KEY',
      'sandstein_routeid': 'INT',
    },
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
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, globalDbName);
    print(path);
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

    /// mapping views for Teufelsturm
    // mapping between TT and sandsteinklettern
    db.execute(
      '''
      CREATE VIEW tt_mapping_areas_view AS
        SELECT 10 as tt_areaid, 123 as sandstein_areaid --	Affensteine
        UNION
        SELECT 2, 124 --	Bielatal
        UNION
        SELECT 11, 125 --	Erzgebirgsgrenzgebiet
        UNION
        SELECT 9, 126 --	Großer Zschand
        UNION
        SELECT 13, 127 --	Hinterhermsdorf
        UNION
        SELECT 7, 128 --	Brand
        UNION
        SELECT 8, 129 --	Kleiner Zschand
        UNION
        SELECT 5, 130 --	Rathen
        UNION
        SELECT 4, 131 --	Schmilka
        UNION
        SELECT 3, 132 --	Schrammsteine
        UNION
        SELECT 1, 133 --	Gebiet der Steine
        UNION
        SELECT 6, 134 --	Wehlen
        UNION
        SELECT 12, 135 --	Wildensteiner Gebiet
      ''',
    );

    db.execute('''
        CREATE VIEW tt_mapping_rocks_view AS 
        /*
        only 3 Rocks are missing in DB Sandsteinklettern
        */
        SELECT tt_rocks.id as tt_rockid, gipfel.gipfel_id as sandstein_rockid
        FROM tt_rocks
          INNER JOIN tt_mapping_areas -- or tt_mapping_areas_view
          ON tt_areaid = tt_rocks.areaid
          INNER JOIN gipfel
          ON sandstein_areaid = sektorid
        AND
        (
        name = gipfelname_d collate nocase
        OR 
        name = REPLACE(gipfelname_d,'ss','ß') collate nocase
        OR 
        name = REPLACE(gipfelname_d,'ß','sz') collate nocase
        OR 
        name = REPLACE(gipfelname_d, ' (Dreifreundeturm)','') collate nocase --Pascher
        OR 
        name = REPLACE(gipfelname_d, ' (Einsamer Turm)','') collate nocase --Gemeinschaftsturm
        OR 
        name = REPLACE(gipfelname_d, ' (Osterspitze)','') collate nocase --Keule
        OR 
        name = REPLACE(gipfelname_d, ' (Ameisenturm)','') collate nocase --Rabensteinturm
        OR 
        name = REPLACE(gipfelname_d, ' (Späte Zinne)','') collate nocase --Rätselturm
        OR 
        name = REPLACE(gipfelname_d, ' (Hänsel)','') collate nocase --Rätselturm
        OR 
        name = REPLACE(gipfelname_d, ' (Brandriff)','') collate nocase --Lößnitzturm
        OR 
        name = REPLACE(gipfelname_d, ' (Stumpfes Horn)','') collate nocase --Meilerstein
        OR 
        name = REPLACE(gipfelname_d, ' (Rotweinspitze)','') collate nocase --Tarzan
        OR 
        name = REPLACE(gipfelname_d, ' (Buchfinkenturm)','') collate nocase --Pfaffenkopf
        OR 
        name = REPLACE(gipfelname_d, ' (Pilzturm)','') collate nocase --Pilzwand
        OR 
        name = REPLACE(gipfelname_d, ' (Rauensteinscheibe)','') collate nocase --Panoramascheibe
        OR 
        name = REPLACE(gipfelname_d, ' (Kapellenwand)','') collate nocase --Dornröschen
        OR 
        name = REPLACE(gipfelname_d, 'Waldschrat','Waldschratt') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Großer Felsenbrückenturm','Felsenbrückenturm') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Liebespaar, Südturm','Südturm Liebespaar') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Liebespaar, Nordturm','Nordturm Liebespaar') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Gralsburg, Nordostzinne','NO-Zinne Gralsburg') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Gralsburg, Südwestzinne','SW-Zinne Gralsburg') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Friedensturm (Pilzturm)','Pilzturm') collate nocase
        OR 
        name = REPLACE(gipfelname_d, '1. Zerborstener Turm','Erster Zerborstener Turm') collate nocase
        OR 
        name = REPLACE(gipfelname_d, '2. Zerborstener Turm','Zweiter Zerborstener Turm') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Festung Königstein','Königstein') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Lilienstein - Westecke','Lilienstein-Westecke') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Pfaffenkopf (Buchfinkenturm)','Buchfinkenturm') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Zwergfels','Zwerg') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Fünf Gipfel, Südturm','Südturm Fünf Gipfel') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Fünf Gipfel, Nordwestturm','Nordwestturm Fünf Gipfel') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Fünf Gipfel, Nordostturm','Nordostturm Fünf Gipfel') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Siamesische Zwillinge, Doof','Doof Siamesische Zwillinge') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Siamesische Zwillinge, Dick','Dick Siamesische Zwillinge') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Lokomotive-Esse','Lokomotive - Esse') collate nocase
        OR 
        name = REPLACE(gipfelname_d, 'Burgenerturm','Burgener Turm') collate nocase
        )    
    ''');
    db.execute('''
        CREATE VIEW tt_mapping_routes_view AS
        /*
        lots of routes are still missing
        */
        SELECT id as tt_routeid, weg_id as sandstein_routeid
        FROM "tt_routes"
          INNER JOIN tt_mapping_rocks -- or tt_mapping_rocks_view
          ON tt_rockid = rockid
          INNER JOIN wege
          ON sandstein_rockid = gipfelid
          AND 
          (
          name = wegname_d collate nocase
          OR
          REPLACE(name, 'AW', 'Alter Weg') = REPLACE(wegname_d, '*', '')
          OR 
          REPLACE(name, 'ß', 'ss') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          REPLACE(name, 'NW-', 'Nordwest') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          REPLACE(name, 'N-', 'Nord') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          REPLACE(name, 'NO-', 'Nordost') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          REPLACE(name, 'O-', 'Ost') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          REPLACE(name, 'SO-', 'Südost') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          REPLACE(name, 'S-', 'Süd') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          REPLACE(name, 'SW-', 'Südwest') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          REPLACE(name, 'W-', 'West') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          REPLACE(name, 'Var.', 'Variante') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          REPLACE(name, 'EV', 'Variante') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          REPLACE(name, 'EV', 'Einstiegsvariante') = REPLACE(wegname_d, '*', '') collate nocase
          OR 
          name = TRIM(REPLACE(wegname_d,'*','')) collate nocase
          )
        GROUP BY id -- because der is duplicates in db-sandsteinklettern
      ''');
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
