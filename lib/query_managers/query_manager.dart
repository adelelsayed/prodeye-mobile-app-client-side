import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:prodeye/http_tools/http_interface.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/logger/logger_levels.dart';
import 'package:prodeye/models/settings.dart';

class QueryManager {
  bool isPrepared = false;
  bool isQuerying = false;
  String parentId = "";
  List<int> qKey = [];
  List<List<int>> cacheEdges = [];
  List<Map<String, Object?>> queryMapsList = [];
  Future<void> prepare(var parentObject) async {}
  Future<void> query(var parentObject, {bool forcedbQuery = false}) async {}
  Future<void> lookUpCache(var parentObject) async {
    try {
      ProdEyeSettings settingsObj = await ProdEyeSettings.getSettings();
      PIHttp request = PIHttp(
          Uri.parse(
              "http://${InternetAddress.loopbackIPv4.address.toString()}:${settingsObj.internalCacheServicePort.toString()}/"),
          {}, (response) {
        if (response.statusCode == 200) {
          var retVal = json.decode(response.body);

          Map<String, dynamic> edges =
              List<Map<String, dynamic>>.from(retVal["edges"])[0];
          List<Map<String, dynamic>> data =
              List<Map<String, dynamic>>.from(retVal["data"]);

          int start = int.parse(edges["start"].toString());
          int end = int.parse(edges["end"].toString());

          if (start != 0 && start < qKey[0]) {
            cacheEdges.add([start, qKey[0]]);
          }
          if (end != 0 && end > qKey[1]) {
            cacheEdges.add([end, qKey[1]]);
          }
          //returned data list is empty and query has not been ran for the past 5 minutes
          String lastCacheDateTimeString = edges["lastCacheDateTime"];
          DateTime lastCacheDateTime = DateTime.parse(lastCacheDateTimeString);
          if (data.isEmpty &&
              DateTime.now().difference(lastCacheDateTime).inMinutes > 5) {
            cacheEdges.add(qKey);
          }
          queryMapsList =
              data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      });
      request.headerMap
          .addAll({"prodId": parentObject.ProductionParent.id.toString()});
      request.headerMap.addAll({"compId": parentObject.id.toString()});
      request.headerMap.addAll({"dataKey": runtimeType.toString()});
      request.headerMap.addAll({"from": qKey[0].toString()});
      request.headerMap.addAll({"to": qKey[1].toString()});

      await request.get().onError((error, stackTrace) {
        ProdiLog.error(ProdiLogLevels.error, runtimeType.toString(),
            "error in lookUpCache ${error.toString()}",
            stackTrace: stackTrace.toString());
        //direct app to query db as long as cache is empty
        cacheEdges.add(qKey);
      });
    } catch (error, stack) {
      ProdiLog.error(ProdiLogLevels.error, runtimeType.toString(),
          "error in lookUpCache ${error.toString()}",
          stackTrace: stack.toString());
    }
  }
}
