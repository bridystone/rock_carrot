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

  // TODO: get rid of - no usage of runtimetype!
  static const databaseRuntimetypeTables = {
    'Countries': 'land',
    'Areas': 'gebiet',
    'Subareas': 'teilgebiet',
    'Rocks': 'gipfel',
    'Routes': 'wege',
    'Comments': 'komment',
  };

  // TODO: transform hash to different hash -> remove name & type
  // will make it more prone to null-issues
  static const databaseTableColumns = {
    'land': [
      {'name': 'land', 'type': 'TEXT PRIMARY KEY'},
      {'name': 'ISO3166', 'type': 'TEXT'},
      {'name': 'KFZ', 'type': 'TEXT'},
    ],
    // json query key: land
    'gebiet': [
      {'name': 'gebiet_ID', 'type': 'INT PRIMARY KEY'},
      {'name': 'gebiet', 'type': 'TEXT'},
      {'name': 'land', 'type': 'TEXT'},
      {'name': 'sprache2', 'type': 'TEXT'},
      {'name': 'gdefaultanzeige', 'type': 'TEXT'},
      {'name': 'schwskala', 'type': 'TEXT'},
    ],
    // json query key: gebietid
    'teilgebiet': [
      {'name': 'sektor_ID', 'type': 'INT PRIMARY KEY'},
      {'name': 'gebietid', 'type': 'INT'},
      {'name': 'sektornr', 'type': 'TEXT'},
      {'name': 'sektorname_d', 'type': 'TEXT'},
      {'name': 'sektorname_cz', 'type': 'TEXT'},
    ],
    // json query key: sektorid
    'gipfel': [
      {'name': 'gipfel_ID', 'type': 'INT PRIMARY KEY'},
      {'name': 'gipfelnr', 'type': 'TEXT'},
      {'name': 'gipfelname_d', 'type': 'TEXT'},
      {'name': 'gipfelname_cz', 'type': 'TEXT'},
      {'name': 'status', 'type': 'TEXT'},
      {'name': 'typ', 'type': 'TEXT'},
      {'name': 'vgrd', 'type': 'TEXT'},
      {'name': 'ngrd', 'type': 'TEXT'},
      {'name': 'posfehler', 'type': 'TEXT'},
      {'name': 'schartenhoehe', 'type': 'TEXT'},
      {'name': 'talhoehe', 'type': 'TEXT'},
      {'name': 'sektorid', 'type': 'INT'},
    ],
    // json query key: sektorid
    'wege': [
      {'name': 'weg_ID', 'type': 'INT PRIMARY KEY'},
      {'name': 'gipfelid', 'type': 'INT'},
      {'name': 'schwierigkeit', 'type': 'TEXT'},
      {'name': 'erstbegvorstieg', 'type': 'TEXT'},
      {'name': 'erstbegnachstieg', 'type': 'TEXT'},
      {'name': 'erstbegdatum', 'type': 'TEXT'},
      {'name': 'ringzahl', 'type': 'TEXT'},
      {'name': 'wegbeschr_d', 'type': 'TEXT'},
      {'name': 'wegbeschr_cz', 'type': 'TEXT'},
      {'name': 'kletterei', 'type': 'TEXT'},
      {'name': 'wegname_d', 'type': 'TEXT'},
      {'name': 'wegname_cz', 'type': 'TEXT'},
      {'name': 'wegstatus', 'type': 'TEXT'},
      {'name': 'wegnr', 'type': 'TEXT'},
      {'name': 'sektorid', 'type': 'INT'},
    ],
    // json query keys: gebietid or sektorid
    'komment': [
      {'name': 'komment_ID', 'type': 'INT PRIMARY KEY'},
      {'name': 'userid', 'type': 'INT'},
      {'name': 'datum', 'type': 'TEXT'},
      {'name': 'adatum', 'type': 'TEXT'},
      {'name': 'wegid', 'type': 'INT'},
      {'name': 'sektorid', 'type': 'INT'},
      {'name': 'gebietid', 'type': 'INT'},
      {'name': 'qual', 'type': 'TEXT'},
      {'name': 'sicher', 'type': 'TEXT'},
      {'name': 'nass', 'type': 'TEXT'},
      {'name': 'kommentar', 'type': 'TEXT'},
      {'name': 'gipfelid', 'type': 'TEXT'},
      {'name': 'schwer', 'type': 'TEXT'},
      {'name': 'geklettert', 'type': 'TEXT'},
      {'name': 'begehung', 'type': 'TEXT'},
    ],
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
    // final databasesPath =
    //     '/sdcard/Android/data/com.example.yacguide_flutter/'; //ONLY FOR TESTING ON Emulator
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, globalDbName);
    // Make sure the directory exists
    try {
      await Directory(databasesPath).create(recursive: true);
      if (resetDatabase) await File(path).delete();
    } catch (e) {
      print('failed to create directory or delete database:' + e.toString());
    }
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
      for (var column in columns) {
        createString += column['name']! + ' ' + column['type']! + ',';
      }
      createString = createString.substring(0, createString.length - 1) + ')';
      db.execute(createString);
    });
    /*
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
        */
  }

  /// Inserts a Country row into the database
  FutureOr<int> insertDataFromJson(
      String tableName, Map<String, dynamic> jsonData) {
    return database.then((db) => db.insert(tableName, jsonData));
  }
}
