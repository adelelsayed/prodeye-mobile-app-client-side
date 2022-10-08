import 'dart:developer';
import 'dart:convert';
import 'package:prodeye/http_tools/http_interface.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:prodeye/models/component_job.dart';
import 'package:prodeye/query_managers/query_manager.dart';

class ComponentJobQuery extends QueryManager {
  List<ComponentJob> componentJobs = [];
  ComponentJobQuery(String pParentId, List<int> pQKey) {
    parentId = pParentId;
    qKey = pQKey;
  }
  @override
  Future<void> prepare(var parentObject) async {
    if (!this.isPrepared) {
      await query(parentObject);
      for (Map<String, Object?> element in queryMapsList) {
        ComponentJob currComponentJob = ComponentJob(
            jobId: int.parse(element["jobId"].toString()),
            status: element["status"].toString(),
            qKey: int.parse(element["qKey"].toString()));
        currComponentJob.componentParent = parentObject;
        currComponentJob.id = int.parse(element["ID"].toString());
        componentJobs.add(currComponentJob);
      }
      ;
    }
    this.isPrepared = true;
  }

  @override
  Future<void> query(var parentObject, {bool forcedbQuery = false}) async {
    //FlutterBackgroundService().invoke("update", {});

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
            await ComponentJob.queryByPropertyList(
                ["componentParent", "qKey"],
                ["=", "between"],
                [int.parse(parentId), "${edge[0]} and ${edge[1]}"]);
        queryMapsList = [...queryMapsList, ...pQueryMapsList];
      }
    }
    this.isQuerying = false;
  }
}
