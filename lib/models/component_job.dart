import 'package:prodeye/models/model_abstract.dart';
import 'package:prodeye/models/component.dart';

class ComponentJob extends ModelProdEye {
  int id = 0;
  int jobId = 0;
  String status = "";
  late Component componentParent;
  int qKey = 0;

  ComponentJob({required this.jobId, required this.status, required this.qKey});

  @override
  List<String> getsqlCreateTableStatement() {
    return [
      "CREATE TABLE ${this.runtimeType.toString()} (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, jobId INTEGER , status TEXT, qKey INTEGER,componentParent INTEGER, FOREIGN KEY(componentParent) REFERENCES Component(id) );",
      "CREATE INDEX ${this.runtimeType.toString()}_ParentIndex ON ${this.runtimeType.toString()}(componentParent);",
      "CREATE INDEX ${this.runtimeType.toString()}_QKeyIndex ON ${this.runtimeType.toString()}(qKey);",
      "CREATE INDEX ${this.runtimeType.toString()}_ParentKeyIndex ON ${this.runtimeType.toString()}(componentParent,qKey);"
    ];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> retVal = {
      "status": status,
      "jobId": jobId,
      "componentParent": componentParent.id,
      "qKey": qKey
    };
    if (id != 0) {
      retVal["ID"] = id;
    }
    return retVal;
  }

  ComponentJob.fromQueryMap(Map<String, dynamic> compJobMap) {
    id = int.parse(compJobMap["ID"].toString());
    jobId = int.parse(compJobMap["jobId"].toString());
    status = compJobMap["status"].toString();
    qKey = int.parse(compJobMap["qKey"].toString());
    Component componentParentObj = Component(
        name: compJobMap["componentParentName"],
        type: compJobMap["componentParentType"]);
    componentParentObj.id = int.parse(compJobMap["componentParent"].toString());
  }

  static Future<void> purge(int pQkey) async {
    List<Map<String, Object?>> querySet =
        await ComponentJob.query("qKey", "<=", pQkey);
    List<ComponentJob> objList =
        querySet.map((e) => ComponentJob.fromQueryMap(e)).toList();
    for (var obj in objList) {
      await obj.delete("ID", "=");
    }
  }

  static Future<List<Map<String, Object?>>> query(
      String property, String operator, dynamic value) async {
    List<Map<String, Object?>> querySet =
        await ModelProdEye.query("ComponentJob", property, operator, value);
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
            "ComponentJob", properties, operators, values);
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
