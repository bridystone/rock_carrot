import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

const String globalDbName = 'sandsteinklettern.db';

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
      if (resetDatabase) await File(path).delete();
    } catch (_) {
      print('failed');
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
  FutureOr<void> _onCreate(Database db, dynamic id) async {
    print('create Tables');
    await db.execute(
        'CREATE TABLE land (land TEXT PRIMARY KEY, ISO3166 TEXT, KFZ TEXT)');
    await db.execute(/*json-query-key:land*/
        'CREATE TABLE gebiet (gebiet_ID INT PRIMARY KEY, gebiet TEXT, land TEXT, sprache2 TEXT, gdefaultanzeige TEXT, schwskala TEXT)');
    await db.execute(/*json-query-key:gebietid*/
        'CREATE TABLE teilgebiet (sektor_ID INT PRIMARY KEY, gebietid INT, sektornr INT, sektorname_d TEXT, sektorname_cz TEXT)');
    await db.execute(/*json-query-key:sektorid*/
        'CREATE TABLE gipfel (gipfel_ID INT PRIMARY KEY, gipfelnr TEXT, gipfelname_d TEXT, gipfelname_cz TEXT, status TEXT, typ TEXT, vgrd TEXT, ngrd TEXT, posfehler TEXT, schartenhoehe TEXT, talhoehe TEXT, sektorid INT)');
    await db.execute(/*json-query-key:sektorid*/
        'CREATE TABLE wege (weg_ID INT PRIMARY KEY, gipfelid INT, schwierigkeit TEXT, erstbegvorstieg TEXT, erstbegnachstieg TEXT, erstbegdatum TEXT, ringzahl TEXT, wegbeschr_d TEXT, wegbeschr_cz TEXT, kletterei TEXT, wegname_d TEXT, wegname_cz TEXT, wegstatus TEXT, wegnr INT, sektorid INT)');
    await db.execute(/*json-query-key:sektorid*/
        'CREATE TABLE komment (komment_ID INT PRIMARY KEY, userid INT, datum TEXT, adatum TEXT, wegid INT, sektorid INT, gebietid INT, qual TEXT, sicher TEXT, nass TEXT, kommentar TEXT, gipfelid INT, schwer TEXT, geklettert TEXT, begehung TEXT)');
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
    return database.then((db) => db.rawQuery(
          'SELECT land.land, COUNT(gebiet) as count'
          ' FROM land'
          ' LEFT OUTER JOIN gebiet'
          ' ON land.land = gebiet.land'
          ' GROUP BY land.land',
        ));
  }

  /*
    area stuff
    */
  FutureOr<int> deleteAreas(String land) async {
    return database.then(
      (db) => db.delete(
        'gebiet',
        where: 'land = ?',
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
    return database.then((db) => db.rawQuery(
          'SELECT gebiet_ID, gebiet, COUNT(teilgebiet.gebietid) as count'
          ' FROM gebiet'
          ' LEFT OUTER JOIN teilgebiet'
          ' ON gebiet.gebiet_ID = teilgebiet.gebietid'
          ' WHERE land = ?'
          ' GROUP BY gebiet.gebiet_ID',
          [land],
        ));
  }

  /*
    Subarea stuff
    */
  FutureOr<int> deleteSubareas(int gebietid) async {
    return database.then(
      (db) => db.delete(
        'teilgebiet',
        where: 'gebietid = ?',
        whereArgs: [gebietid],
      ),
    );
  }

  FutureOr<int> insertSubareas(
    int sektorID,
    int gebietid,
    int sektornr,
    String sektornameD,
    String sektornameCZ,
  ) async {
    return database.then((db) => db.insert(
          'teilgebiet',
          {
            'sektor_ID': sektorID,
            'gebietid': gebietid,
            'sektornr': sektornr,
            'sektorname_d': sektornameD,
            'sektorname_cz': sektornameCZ,
          },
        ));
  }

  Future<List<Map<String, Object?>>> querySubareas(int gebietid) async {
    return database.then((db) => db.rawQuery(
          'SELECT sektor_ID, sektornr, sektorname_d, sektorname_cz, COUNT(gipfel.sektorid) as count'
          ' FROM teilgebiet'
          ' LEFT OUTER JOIN gipfel'
          ' ON teilgebiet.sektor_ID = gipfel.sektorid'
          ' WHERE gebietid = ?'
          ' GROUP BY teilgebiet.sektor_ID',
          [gebietid],
        ));
  }

  /*
    Gipfel stuff
    */
  FutureOr<int> deleteGipfels(int sektorid) async {
    return database.then(
      (db) => db.delete(
        'gipfel',
        where: 'sektorid = ?',
        whereArgs: [sektorid],
      ),
    );
  }

  FutureOr<int> insertGipfels(
    int gipfelID,
    String gipfelnr,
    String gipfelnameD,
    String gipfelnameCZ,
    String status,
    String typ,
    String vgrd,
    String ngrd,
    String posfehler,
    String schartenhoehe,
    String talhoehe,
    int sektorid,
  ) async {
    return database.then((db) => db.insert(
          'gipfel',
          {
            'gipfel_ID': gipfelID,
            'gipfelnr': gipfelnr,
            'gipfelname_D': gipfelnameD,
            'gipfelname_CZ': gipfelnameCZ,
            'status': status,
            'typ': typ,
            'vgrd': vgrd,
            'ngrd': ngrd,
            'posfehler': posfehler,
            'schartenhoehe': schartenhoehe,
            'talhoehe': talhoehe,
            'sektorid': sektorid,
          },
        ));
  }

  Future<List<Map<String, Object?>>> queryGipfels(
    int sektorid,
  ) async {
    return database.then((db) => db.rawQuery(
          'SELECT gipfel_ID, gipfelnr, gipfelname_d, gipfelname_cz, '
          '   status, typ, schartenhoehe, talhoehe, gipfel.sektorid, '
          '   COUNT(wege.gipfelid) as count'
          ' FROM gipfel'
          '   LEFT OUTER JOIN wege'
          '   ON gipfel.gipfel_ID = wege.gipfelid'
          ' WHERE gipfel.sektorid = ?'
          ' GROUP BY gipfel.gipfel_id',
          [sektorid],
        ));
  }

  /*
    Wege stuff
    */
  FutureOr<int> deleteWege(int sektorid) async {
    return database.then(
      (db) => db.delete(
        'wege',
        where: 'sektorid = ?',
        whereArgs: [sektorid],
      ),
    );
  }

  FutureOr<int> insertWege(
    int wegID,
    int gipfelid,
    String schwierigkeit,
    String erstbegvorstieg,
    String erstbegnachstieg,
    String erstbegdatum,
    String ringzahl,
    String wegbeschrD,
    String wegbeschrCZ,
    String kletterei,
    String wegnameD,
    String wegnameCZ,
    String wegstatus,
    String wegnr,
    int sektorid,
  ) async {
    return database.then((db) => db.insert(
          'wege',
          {
            'sektorid': sektorid,
            'weg_ID': wegID,
            'gipfelid': gipfelid,
            'schwierigkeit': schwierigkeit,
            'erstbegvorstieg': erstbegvorstieg,
            'erstbegnachstieg': erstbegnachstieg,
            'erstbegdatum': erstbegdatum,
            'ringzahl': ringzahl,
            'wegbeschr_d': wegbeschrD,
            'wegbeschr_cz': wegbeschrCZ,
            'kletterei': kletterei,
            'wegname_d': wegnameD,
            'wegname_cz': wegnameCZ,
            'wegstatus': wegstatus,
            'wegnr': wegnr,
          },
        ));
  }

  Future<List<Map<String, Object?>>> queryWege(
    int gipfelid,
  ) async {
    return database.then((db) => db.query(
          'wege',
          columns: [
            'sektorid',
            'Weg_ID',
            'gipfelid',
            'schwierigkeit',
            'ringzahl',
            'wegbeschr_d',
            'wegbeschr_cz',
            'kletterei',
            'wegname_d',
            'wegname_cz',
            'wegstatus',
            'wegnr'
          ],
          where: 'gipfelid = ?',
          whereArgs: [gipfelid],
        ));
  }

  /*
    Komment stuff
    */
  FutureOr<int> deleteComment(int sektorid) async {
    return database.then(
      (db) => db.delete(
        'komment',
        where: 'sektorid = ?',
        whereArgs: [sektorid],
      ),
    );
  }

  FutureOr<int> insertComment(
    int kommentID,
    int userid,
    String datum,
    String adatum,
    int wegid,
    int sektorid,
    int gebietid,
    String qual,
    String sicher,
    String nass,
    String kommentar,
    int gipfelid,
    String schwer,
    String geklettert,
    String begehung,
  ) async {
    return database.then((db) => db.insert(
          'gebiet',
          {
            'komment_ID': kommentID,
            'userid': userid,
            'datum': datum,
            'adatum': adatum,
            'wegid': wegid,
            'sektorid': sektorid,
            'gebietid': gebietid,
            'qual': qual,
            'sicher': sicher,
            'nass': nass,
            'kommentar': kommentar,
            'gipfelid': gipfelid,
            'schwer': schwer,
            'geklettert': geklettert,
            'begehung': begehung,
          },
        ));
  }

  Future<List<Map<String, Object?>>> queryComment(
    int sektorid,
    int gipfelid,
    int wegid,
  ) async {
    return database.then((db) => db.query(
          'komment',
          columns: [
            'qual',
            'sicher',
            'nass',
            'kommentar',
            'schwer',
            'geklettert',
            'begehung'
          ],
          where: 'sektorid = ? AND gipfelid = ? AND wegid = ?',
          whereArgs: [sektorid, gipfelid, wegid],
        ));
  }
}
