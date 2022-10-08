import 'dart:developer';
import 'package:prodeye/models/component_queue_and_messages.dart';
import 'package:prodeye/models/model_abstract.dart';
import 'package:prodeye/query_managers/query_manager.dart';

import 'package:prodeye/storage_apis/sql_store.dart';
import 'package:sqflite/sqflite.dart';

class ComponentQueueMessageStatsQuery extends QueryManager {
  List<ComponentQueueMessageStats> componentQueueMessageStats = [];
  ComponentQueueMessageStatsQuery(String pParentId, List<int> pQKey) {
    parentId = pParentId;
    qKey = pQKey;
  }
  @override
  Future<void> prepare(var parentObject) async {
    if (!this.isPrepared) {
      await query(parentObject);
      for (Map<String, Object?> element in queryMapsList) {
        ComponentQueueMessageStats currComponentQMStats =
            ComponentQueueMessageStats(
                int.parse(element["isEnabled"].toString()),
                int.parse(element["queueSize"].toString()),
                int.parse(element["messageCount"].toString()),
                int.parse(
                    element["messageAVGProcessingMilliseconds"].toString()),
                int.parse(element["qKey"].toString()));
        currComponentQMStats.componentParent = parentObject;
        currComponentQMStats.id = int.parse(element["ID"].toString());
        componentQueueMessageStats.add(currComponentQMStats);
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
            await ComponentQueueMessageStats.queryByPropertyList(
                ["componentParent", "qKey", "isEnabled"],
                ["=", "between", "="],
                [int.parse(parentId), "${edge[0]} and ${edge[1]}", 1]);

        queryMapsList = [...queryMapsList, ...pQueryMapsList];
      }
    }
    this.isQuerying = false;
  }
}
