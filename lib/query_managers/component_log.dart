import 'dart:developer';

import 'package:prodeye/models/component_log.dart';
import 'package:prodeye/query_managers/query_manager.dart';
import 'package:prodeye/storage_apis/sql_utils.dart';

class ComponentLogQuery extends QueryManager {
  List<ComponentLog> componentLogs = [];

  String get logType {
    return "";
  }

  ComponentLogQuery(String pParentId, List<int> pQKey) {
    parentId = pParentId;
    qKey = pQKey;
  }

  @override
  Future<void> prepare(var parentObject) async {
    if (!this.isPrepared) {
      await query(parentObject);
      for (Map<String, Object?> element in queryMapsList) {
        ComponentLog currComponentLog = ComponentLog(
            type: element["type"].toString(),
            sessionId: int.parse(element["sessionId"].toString()),
            logMessage: element["logMessage"].toString(),
            logTime: element["logTime"].toString(),
            qKey: int.parse(element["qKey"].toString()));
        currComponentLog.componentParent = parentObject;
        currComponentLog.id = int.parse(element["ID"].toString());
        componentLogs.add(currComponentLog);
      }
    }
    this.isPrepared = true;
  }

  @override
  Future<void> query(var parentObject, {bool forcedbQuery = false}) async {
    if (!this.isQuerying) {
      queryMapsList = [];
      if (!forcedbQuery) {
        await lookUpCache(parentObject);
      } else {
        cacheEdges = [qKey];
      }

      for (List<int> edge in cacheEdges) {
        this.isQuerying = true;
        List<Map<String, Object?>> pQueryMapsList =
            await ComponentLog.queryByPropertyList([
          "componentParent",
          "qKey",
          "type"
        ], [
          "=",
          "between",
          "="
        ], [
          int.parse(parentId),
          "${edge[0]} and ${edge[1]}",
          getSqlString(logType)
        ]);
        queryMapsList = [...queryMapsList, ...pQueryMapsList];
      }
    }
    this.isQuerying = false;
  }
}

class ComponentErrors extends ComponentLogQuery {
  @override
  String logType = "Error";
  ComponentErrors(String pParentId, List<int> pQKey) : super(pParentId, pQKey);
}

class ComponentWarnings extends ComponentLogQuery {
  @override
  String logType = "Warning";
  ComponentWarnings(String pParentId, List<int> pQKey)
      : super(pParentId, pQKey);
}

class ComponentAlerts extends ComponentLogQuery {
  @override
  String logType = "Alert";
  ComponentAlerts(String pParentId, List<int> pQKey) : super(pParentId, pQKey);
}
