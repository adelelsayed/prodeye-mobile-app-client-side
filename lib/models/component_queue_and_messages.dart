import 'package:prodeye/models/component.dart';
import 'package:prodeye/models/model_abstract.dart';

class ComponentQueueMessageStats extends ModelProdEye {
  int id = 0;
  late Component componentParent;
  bool isEnabled = false;
  int queueSize = 0;
  int messageCount = 0;
  int messageAVGProcessingMilliseconds = 0;
  int qKey = 0;

  ComponentQueueMessageStats(int pIsEnabled, int pQueueSize, int pMessageCount,
      int pMessageAVG, int pQKey) {
    isEnabled = pIsEnabled == 1 ? true : false;
    queueSize = pQueueSize;
    messageCount = pMessageCount;
    messageAVGProcessingMilliseconds = pMessageAVG;
    qKey = pQKey;
  }

  @override
  List<String> getsqlCreateTableStatement() {
    return [
      "CREATE TABLE ${this.runtimeType.toString()} (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, isEnabled INTEGER , queueSize INTEGER, messageCount INTEGER,messageAVGProcessingMilliseconds INTEGER, qKey INTEGER,componentParent INTEGER, FOREIGN KEY(componentParent) REFERENCES Component(id) );",
      "CREATE INDEX ${this.runtimeType.toString()}_ParentIndex ON ${this.runtimeType.toString()}(componentParent);",
      "CREATE INDEX ${this.runtimeType.toString()}_EnabledIndex ON ${this.runtimeType.toString()}(isEnabled);",
      "CREATE INDEX ${this.runtimeType.toString()}_QKeyIndex ON ${this.runtimeType.toString()}(qKey);",
      "CREATE INDEX ${this.runtimeType.toString()}_ParentEnabledKeyIndex ON ${this.runtimeType.toString()}(componentParent,isEnabled,qKey);"
    ];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> retVal = {
      "isEnabled": isEnabled ? 1 : 0,
      "queueSize": queueSize,
      "messageCount": messageCount,
      "messageAVGProcessingMilliseconds": messageAVGProcessingMilliseconds,
      "componentParent": componentParent.id,
      "qKey": qKey
    };
    if (id != 0) {
      retVal["ID"] = id;
    }
    return retVal;
  }

  ComponentQueueMessageStats.fromQueryMap(Map<String, dynamic> compStatsMap) {
    id = int.parse(compStatsMap["ID"].toString());
    qKey = int.parse(compStatsMap["qKey"].toString());
    isEnabled =
        int.parse(compStatsMap["isEnabled"].toString()) == 1 ? true : false;
    queueSize = int.parse(compStatsMap["queueSize"].toString());
    messageCount = int.parse(compStatsMap["messageCount"].toString());
    messageAVGProcessingMilliseconds =
        int.parse(compStatsMap["messageAVGProcessingMilliseconds"].toString());
    Component componentParentObj = Component(
        name: compStatsMap["componentParentName"],
        type: compStatsMap["componentParentType"]);
    componentParentObj.id =
        int.parse(compStatsMap["componentParent"].toString());
  }

  static Future<void> purge(int pQkey) async {
    List<Map<String, Object?>> querySet =
        await ComponentQueueMessageStats.query("qKey", "<=", pQkey);
    List<ComponentQueueMessageStats> objList = querySet
        .map((e) => ComponentQueueMessageStats.fromQueryMap(e))
        .toList();
    for (var obj in objList) {
      await obj.delete("ID", "=");
    }
  }

  static Future<List<Map<String, Object?>>> query(
      String property, String operator, dynamic value) async {
    List<Map<String, Object?>> querySet = await ModelProdEye.query(
        "ComponentQueueMessageStats", property, operator, value);
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
            "ComponentQueueMessageStats", properties, operators, values);
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
