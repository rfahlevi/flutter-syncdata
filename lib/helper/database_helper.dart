// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../model/person.dart';

class DatabaseHelper {
  final String _dbName = 'sync.db';
  final int _dbVersion = 1;
  final String personTable = 'person';

  Database? _database;

  Future<Database> init() async {
    if (_database != null) return _database!;
    _database = await _initDb();
    print(_database?.isOpen);
    return _database!;
  }

  Future _initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = p.join(directory.path, _dbName);
    return openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $personTable (id INTEGER PRIMARY KEY, name TEXT, age INTEGER, gender TEXT, created_at TEXT NULL, updated_at TEXT NULL)',
    );
  }

  Future<List<Person>> getPersons() async {
    final db = await init();
    var result = await db.query(personTable);
    List<Person> personList = result.map((e) => Person.fromJson(e)).toList();
    log('$personList');
    return personList;
  }

  Future<int> insertToLocal(Person person) async {
    final db = await init();
    final query = await db.insert(personTable, person.toJson());

    return query;
  }

  Future<int> deletePerson(int id) async {
    final db = await init();
    return await db.delete(personTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllPerson() async {
    final db = await init();
    return await db.delete(personTable);
  }
}
