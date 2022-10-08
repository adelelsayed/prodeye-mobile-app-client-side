import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KVStore extends FlutterSecureStorage {
  Future<List<dynamic>> ensureClassInitialized(String classname) async {
    String? classDataList = await read(key: classname);

    if (!(classDataList is String)) {
      await write(key: classname, value: "[]");
      return [];
    } else {
      return List<dynamic>.from(json.decode(classDataList));
    }
  }

  Map<String, dynamic> getListOfIdsFromRecords(List<dynamic> records) {
    Map<String, dynamic> retVal = {};
    for (var record in records) {
      Map<String, dynamic> recordMap =
          Map<String, dynamic>.from(json.decode(record));
      if (recordMap.containsKey("id")) {
        retVal.addAll({recordMap["id"]: record});
      }
    }
    return retVal;
  }

  Future<void> writeRecord(var classObj) async {
    List<dynamic> classDataListofRecords =
        await ensureClassInitialized(classObj.runtimeType.toString());
    Map<String, dynamic> recordsByIds =
        getListOfIdsFromRecords(classDataListofRecords);
    String record = classObj.inToJson();
    if (record != "") {
      if (recordsByIds.keys.contains(classObj.id)) {
        dynamic currentRecord = recordsByIds[classObj.id];
        classDataListofRecords.remove(currentRecord);
      }

      classDataListofRecords.add(record);
    }

    await write(
        key: classObj.runtimeType.toString(),
        value: json.encode(classDataListofRecords));
  }

  Future<List<dynamic>> readAllRecords(String classname) async {
    return await ensureClassInitialized(classname);
  }

  Future<dynamic> readById(String classname, String targetId) async {
    List<dynamic> classDataListofRecords =
        await ensureClassInitialized(classname);
    Map<String, dynamic> recordsByIds =
        getListOfIdsFromRecords(classDataListofRecords);
    if (recordsByIds.keys.contains(targetId)) {
      return recordsByIds[targetId];
    } else {
      throw Exception("$targetId is not found in records of $classname");
    }
  }

  Future<void> deleteEntryById(String classname, String targetId) async {
    List<dynamic> classDataListofRecords =
        await ensureClassInitialized(classname);
    Map<String, dynamic> recordsByIds =
        getListOfIdsFromRecords(classDataListofRecords);
    if (recordsByIds.keys.contains(targetId)) {
      classDataListofRecords.remove(recordsByIds[targetId]);
    }
    await write(key: classname, value: json.encode(classDataListofRecords));
  }
}
