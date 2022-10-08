import 'package:prodeye/models/model_abstract.dart';
import 'package:prodeye/models/component.dart';
import 'package:prodeye/storage_apis/sql_utils.dart';

class ComponentLog extends ModelProdEye {
  int id = 0;
  String type = "";
  int sessionId = 0;
  String logMessage = "";
  String logTime = "";
  late Component componentParent;
  int qKey = 0;

  ComponentLog(
      {required this.type,
      required this.sessionId,
      required this.logMessage,
      required this.logTime,
      required this.qKey});

  @override
  List<String> getsqlCreateTableStatement() {
    return [
      "CREATE TABLE ${this.runtimeType.toString()} (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, sessionId INTEGER , type TEXT , logMessage TEXT , logTime TEXT, qKey INTEGER,componentParent INTEGER, FOREIGN KEY(componentParent) REFERENCES Component(id) );",
      "CREATE INDEX ${this.runtimeType.toString()}_ParentIndex ON ${this.runtimeType.toString()}(componentParent);",
      "CREATE INDEX ${this.runtimeType.toString()}_QKeyIndex ON ${this.runtimeType.toString()}(qKey);",
      "CREATE INDEX ${this.runtimeType.toString()}_TypeIndex ON ${this.runtimeType.toString()}(type);",
      "CREATE INDEX ${this.runtimeType.toString()}_ParentTypeKeyIndex ON ${this.runtimeType.toString()}(componentParent,type,qKey);"
    ];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> retVal = {
      "type": type,
      "sessionId": sessionId,
      "logMessage": logMessage,
      "logTime": logTime,
      "componentParent": componentParent.id,
      "qKey": qKey
    };
    if (id != 0) {
      retVal["ID"] = id;
    }
    return retVal;
  }

  ComponentLog.fromQueryMap(Map<String, dynamic> compLogMap) {
    id = int.parse(compLogMap["ID"].toString());
    type = compLogMap["type"].toString();
    sessionId = int.parse(compLogMap["sessionId"].toString());
    logMessage = compLogMap["logMessage"].toString();
    logTime = compLogMap["logTime"].toString();
    qKey = int.parse(compLogMap["qKey"].toString());
    Component componentParentObj = Component(
        name: compLogMap["componentParentName"],
        type: compLogMap["componentParentType"]);
    componentParentObj.id = int.parse(compLogMap["componentParent"].toString());
  }

  static Future<void> purge(int pQkey, String pType) async {
    List<Map<String, Object?>> querySet =
        await ComponentLog.queryByPropertyList(
            ["qKey", "type"], ["<=", "="], [pQkey, getSqlString(pType)]);
    List<ComponentLog> objList =
        querySet.map((e) => ComponentLog.fromQueryMap(e)).toList();
    for (var obj in objList) {
      await obj.delete("ID", "=");
    }
  }

  static Future<List<Map<String, Object?>>> query(
      String property, String operator, dynamic value) async {
    List<Map<String, Object?>> querySet =
        await ModelProdEye.query("ComponentLog", property, operator, value);
    for (var item in querySet) {
      item = Map<String, Object?>.from(item);
      int parentId = int.parse(item["componentParent"].toString());
      List<Map<String, Object?>> compParentQuerySet =
          await Component.query("ID", "=", parentId);
      if (compParentQuerySet.isNotEmpty) {
        Map<String, Object?> compParent = compParentQuerySet[0];
        item.addAll({"componentParentName": compParent["name"]});
        item.addAll({"componentParentType": compParent["type"]});
      }
    }
    return querySet;
  }

  static Future<List<Map<String, Object?>>> queryByPropertyList(
      List<String> properties,
      List<String> operators,
      List<dynamic> values) async {
    List<Map<String, Object?>> querySet =
        await ModelProdEye.queryByPropertyList(
            "ComponentLog", properties, operators, values);
    for (var item in querySet) {
      item = Map<String, Object?>.from(item);
      int parentId = int.parse(item["componentParent"].toString());
      List<Map<String, Object?>> compParentQuerySet =
          await Component.query("ID", "=", parentId);
      if (compParentQuerySet.isNotEmpty) {
        Map<String, Object?> compParent = compParentQuerySet[0];
        item.addAll({"componentParentName": compParent["name"]});
        item.addAll({"componentParentType": compParent["type"]});
      }
    }
    return querySet;
  }
}
