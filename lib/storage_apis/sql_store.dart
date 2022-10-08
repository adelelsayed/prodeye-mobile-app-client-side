import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

///object must have toMap() method to produce Map and an unique identifier property named id
class SqliteStore {
  Future<Database> getDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();

    final Database database = await openDatabase(
      join(await getDatabasesPath(), 'prodeye.db'),
    );

    return database;
  }

  Future<bool> tableExists(String table, Database dbCon) async {
    List<Map<String, Object?>> tableExist = await dbCon
        .query('sqlite_master', where: 'name = ?', whereArgs: [table]);
    return tableExist.isNotEmpty;
  }

  Future<void> createTable(
      List<String> sqlCreateTableStatements, Database dbCon) async {
    for (String statment in sqlCreateTableStatements) {
      await dbCon.execute(statment);
    }
  }

  Future<int> writeRecord(var classObj, Database dbCon, String conflict) async {
    int rowid = await dbCon.insert(
      classObj.runtimeType.toString(),
      classObj.toMap(),
      conflictAlgorithm: conflict == "replace"
          ? ConflictAlgorithm.replace
          : ConflictAlgorithm.fail,
    );
    return rowid;
  }

  Future<void> deleteRecordByProperty(
      var classObj, Database dbCon, String property, String operator) async {
    await dbCon.delete(classObj.runtimeType.toString(),
        where: '$property $operator ?',
        whereArgs: [classObj.toMap()[property]]);
  }

  Future<void> updateRecordByProperty(
      var classObj, Database dbCon, String property, String operator) async {
    Map<String, Object?> recordMap = classObj.toMap();
    recordMap.remove("ID");

    await dbCon.update(classObj.runtimeType.toString(), recordMap,
        where: '$property $operator ?',
        whereArgs: [classObj.toMap()[property]]);
  }

  Future<List<Map<String, Object?>>> queryRecordByProperty(String classname,
      Database dbCon, String property, String operator, dynamic value) async {
    List<Map<String, Object?>> records = await dbCon
        .query(classname, where: '$property $operator ?', whereArgs: [value]);
    return records;
  }

  Future<List<Map<String, Object?>>> queryRecordByPropertyList(
      String classname,
      Database dbCon,
      List<String> properties,
      List<String> operators,
      List<dynamic> values) async {
    String queryString = properties
        .map((e) =>
            "$e ${operators[properties.indexOf(e)]} ${values[properties.indexOf(e)]} and ")
        .toList()
        .join();
    //remove last and
    queryString =
        "select * from $classname where ${queryString.substring(0, queryString.length - 4)}";
    /*
    List<Map<String, Object?>> pln =
        await dbCon.rawQuery("EXPLAIN QUERY PLAN $queryString");
    log(pln.toString());
    */
    List<Map<String, Object?>> records = await dbCon.rawQuery(queryString);
    return records;
  }
}
