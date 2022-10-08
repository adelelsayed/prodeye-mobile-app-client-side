import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:prodeye/storage_apis/sql_store.dart';

abstract class ModelProdEye {
  static SqliteStore SqlStore = SqliteStore();

  Map<String, dynamic> toMap() {
    return {};
  }

  List<String> getsqlCreateTableStatement() {
    return [];
  }

  Future<int> save({String conflictResolve = ""}) async {
    try {
      Database dbConnection = await SqlStore.getDatabase();
      bool tableExists =
          await SqlStore.tableExists(this.runtimeType.toString(), dbConnection);

      if (!tableExists) {
        SqlStore.createTable(getsqlCreateTableStatement(), dbConnection);
      }

      int rowid =
          await SqlStore.writeRecord(this, dbConnection, conflictResolve);
      return rowid;
    } catch (eError, stackTrace) {
      debugPrint(
          "ProdEye error during db insert using ${this.runtimeType.toString()} Module with error ${eError.toString()} of stack ${stackTrace.toString()}");
      return 0;
    }
  }

  Future<bool> delete(String property, String operator) async {
    try {
      Database dbConnection = await SqlStore.getDatabase();
      bool tableExists =
          await SqlStore.tableExists(this.runtimeType.toString(), dbConnection);
      if (!tableExists) {
        debugPrint(
            "ProdEye error during db delete using ${this.runtimeType.toString()} Module, table not existing!");
        return false;
      }

      await SqlStore.deleteRecordByProperty(
          this, dbConnection, property, operator);
      return true;
    } catch (eError, stackTrace) {
      debugPrint(
          "ProdEye error during db delete using ${this.runtimeType.toString()} Module with error ${eError.toString()} of stack ${stackTrace.toString()}");
      return false;
    }
  }

  Future<bool> update(String property, String operator) async {
    try {
      Database dbConnection = await SqlStore.getDatabase();
      bool tableExists =
          await SqlStore.tableExists(this.runtimeType.toString(), dbConnection);
      if (!tableExists) {
        debugPrint(
            "ProdEye error during db update using ${this.runtimeType.toString()} Module, table not existing!");
        return false;
      }

      await SqlStore.updateRecordByProperty(
          this, dbConnection, property, operator);
      return true;
    } catch (eError, stackTrace) {
      debugPrint(
          "ProdEye error during db update using ${this.runtimeType.toString()} Module with error ${eError.toString()} of stack ${stackTrace.toString()}");
      return false;
    }
  }

  static Future<List<Map<String, Object?>>> query(
      String classname, String property, String operator, dynamic value) async {
    try {
      Database dbConnection = await SqlStore.getDatabase();
      bool tableExists = await SqlStore.tableExists(classname, dbConnection);
      if (!tableExists) {
        debugPrint(
            "ProdEye error during db query using $classname Module, table not existing!");
        return [];
      }

      List<Map<String, Object?>> retVal = await SqlStore.queryRecordByProperty(
          classname, dbConnection, property, operator, value);
      return retVal;
    } catch (eError, stackTrace) {
      debugPrint(
          "ProdEye error during db query using $classname Module with error ${eError.toString()} of stack ${stackTrace.toString()}");
      return [];
    }
  }

  static Future<List<Map<String, Object?>>> queryByPropertyList(
      String classname,
      List<String> properties,
      List<String> operators,
      List<dynamic> values) async {
    try {
      Database dbConnection = await SqlStore.getDatabase();
      bool tableExists = await SqlStore.tableExists(classname, dbConnection);

      if (!tableExists) {
        debugPrint(
            "ProdEye error during db query using $classname Module, table not existing!");
        return [];
      }

      List<Map<String, Object?>> retVal =
          await SqlStore.queryRecordByPropertyList(
              classname, dbConnection, properties, operators, values);
      return retVal;
    } catch (eError, stackTrace) {
      debugPrint(
          "ProdEye error during db query using $classname Module with error ${eError.toString()} of stack ${stackTrace.toString()}");
      return [];
    }
  }
}
