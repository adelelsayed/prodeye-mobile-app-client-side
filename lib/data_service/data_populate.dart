import 'dart:developer';

import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/models/profile.dart';
import 'package:prodeye/models/component.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/models/notification.dart';
import 'package:prodeye/models/production.dart';
import 'package:prodeye/models/component_queue_and_messages.dart';
import 'package:prodeye/models/component_log.dart';
import 'package:prodeye/models/component_job.dart';
import 'package:prodeye/storage_apis/sql_utils.dart';

class PopulateData {
  static populateProdData(
      Map<String, dynamic> responseData, Profile profile) async {
    ProdEyeSettings settingObject = await ProdEyeSettings.getSettings();

    int genericId = DateTime.now().millisecondsSinceEpoch;

    ProdiLog.debug(settingObject.logLevel, "PopulateData.populateProdData",
        "data population process (id:$genericId) started");

    try {
      List<dynamic> documentList = List<dynamic>.from(responseData["content"]);

      ProdiLog.debug(settingObject.logLevel, "PopulateData.populateProdData",
          "data population process (id:$genericId) picked up the payload ${documentList.toString()}");

      for (dynamic document in documentList) {
        ProdiLog.debug(settingObject.logLevel, "PopulateData.populateProdData",
            "data population process (id:$genericId) running on document ${document.toString()}");

        Map<String, dynamic> documentMap = Map<String, dynamic>.from(document);
        List<dynamic> prodList =
            List<dynamic>.from(documentMap["ProductionList"]);
        for (var prod in prodList) {
          Map<String, dynamic> prodMap = Map<String, dynamic>.from(prod);

          Production prodObj = await Production.getOrCreate(prodMap, profile, [
            "name",
            "profileParent"
          ], [
            "=",
            "="
          ], [
            getSqlString(prodMap["Name"].toString()),
            getSqlString(profile.id)
          ]);

          //point of detection of production status change
          if (prodObj.status != prodMap["Status"]) {
            ProdiNotification newNote = ProdiNotification(
                title:
                    "${prodObj.profileParent.name}^${prodObj.name}^Production Status Change",
                body:
                    "Production Status Changed from ${prodObj.status} to ${prodMap["Status"]}",
                prodeyeObjId: prodObj.id,
                prodeyeObjType: "Production",
                qKey: int.parse(prodObj.profileParent.lastQueriedKey));
            newNote.save();

            prodObj.status = prodMap["Status"];
            prodObj.statusAsOf = prodMap["StatusAsOf"];
            await prodObj.update("ID", "=");
          }

          ProdiLog.debug(
              settingObject.logLevel,
              "PopulateData.populateProdData",
              "data population process (id:$genericId) created or updated Production ${prodObj.id}");

          List<dynamic> componentList =
              List<dynamic>.from(prodMap["Components"]);
          for (var comp in componentList) {
            Map<String, dynamic> compMap = Map<String, dynamic>.from(comp);

            Component compObj = await Component.getOrCreate(
                compMap,
                prodObj,
                ["name", "productionParent"],
                ["=", "="],
                [getSqlString(compMap["Name"].toString()), prodObj.id]);

            ProdiLog.debug(
                settingObject.logLevel,
                "PopulateData.populateProdData",
                "data population process (id:$genericId) created or updated Component ${compObj.id}");
            ComponentQueueMessageStats compStatsObj =
                ComponentQueueMessageStats(
                    compMap["IsEnabled"] ? 1 : 0,
                    compMap.containsKey("QueueSize")
                        ? int.parse(compMap["QueueSize"].toString())
                        : 0,
                    compMap.containsKey("MessageCount")
                        ? int.parse(compMap["MessageCount"].toString())
                        : 0,
                    compMap.containsKey("MessageAVGProcessingMilliseconds")
                        ? int.parse(compMap["MessageAVGProcessingMilliseconds"]
                            .toString())
                        : 0,
                    int.parse(documentMap["TimeOfQueryIdx"].toString()));
            compStatsObj.componentParent = compObj;
            compStatsObj.id = await compStatsObj.save();

            ProdiLog.debug(
                settingObject.logLevel,
                "PopulateData.populateProdData",
                "data population process (id:$genericId) created Component stats ${compStatsObj.id}");

            if (compMap.containsKey("JobsStatus")) {
              List<dynamic> compJobs =
                  List<dynamic>.from(compMap["JobsStatus"]);
              for (var job in compJobs) {
                Map<String, dynamic> jobMap = Map<String, dynamic>.from(job);
                ComponentJob jobObj = ComponentJob(
                    jobId: int.parse(jobMap["JobId"].toString()),
                    status: jobMap["Status"],
                    qKey: int.parse(documentMap["TimeOfQueryIdx"].toString()));
                jobObj.componentParent = compObj;
                jobObj.id = await jobObj.save();

                ProdiLog.debug(
                    settingObject.logLevel,
                    "PopulateData.populateProdData",
                    "data population process (id:$genericId) created Component job ${jobObj.id}");
              }
            }

            if (compMap.containsKey("Warnings")) {
              List<dynamic> compWarns = List<dynamic>.from(compMap["Warnings"]);
              for (var warn in compWarns) {
                Map<String, dynamic> warnMap = Map<String, dynamic>.from(warn);
                ComponentLog warnObj = ComponentLog(
                    type: "Warning",
                    sessionId: warnMap.containsKey("SessionId")
                        ? int.parse(warnMap["SessionId"].toString())
                        : 0,
                    logMessage: warnMap["ErrorText"].toString(),
                    logTime: "${warnMap["LogTime"].toString()}Z",
                    qKey: int.parse(documentMap["TimeOfQueryIdx"].toString()));
                warnObj.componentParent = compObj;
                warnObj.id = await warnObj.save();

                ProdiLog.debug(
                    settingObject.logLevel,
                    "PopulateData.populateProdData",
                    "data population process (id:$genericId) created Component warning ${warnObj.id}");
              }
            }

            if (compMap.containsKey("Errors")) {
              List<dynamic> compErrors = List<dynamic>.from(compMap["Errors"]);

              for (var error in compErrors) {
                Map<String, dynamic> errorMap =
                    Map<String, dynamic>.from(error);
                ComponentLog errorObj = ComponentLog(
                    type: "Error",
                    sessionId: errorMap.containsKey("SessionId")
                        ? int.parse(errorMap["SessionId"].toString())
                        : 0,
                    logMessage: errorMap["ErrorText"].toString(),
                    logTime: "${errorMap["LogTime"].toString()}Z",
                    qKey: int.parse(documentMap["TimeOfQueryIdx"].toString()));
                errorObj.componentParent = compObj;
                errorObj.id = await errorObj.save();
                ProdiLog.debug(
                    settingObject.logLevel,
                    "PopulateData.populateProdData",
                    "data population process (id:$genericId) created Component Error ${errorObj.id}");
              }
            }

            if (compMap.containsKey("Alerts")) {
              List<dynamic> compAlerts = List<dynamic>.from(compMap["Alerts"]);
              for (var alert in compAlerts) {
                Map<String, dynamic> alertMap =
                    Map<String, dynamic>.from(alert);
                ComponentLog alertObj = ComponentLog(
                    type: "Alert",
                    sessionId: alertMap.containsKey("SessionId")
                        ? int.parse(alertMap["SessionId"].toString())
                        : 0,
                    logMessage: alertMap["ErrorText"].toString(),
                    logTime: "${alertMap["LogTime"].toString()}Z",
                    qKey: int.parse(documentMap["TimeOfQueryIdx"].toString()));
                alertObj.componentParent = compObj;
                alertObj.id = await alertObj.save();

                ProdiLog.debug(
                    settingObject.logLevel,
                    "PopulateData.populateProdData",
                    "data population process (id:$genericId) created Component Alert ${alertObj.id}");
              }
            }
          }
        }
      }
    } catch (eError, sTackTrace) {
      ProdiLog.error(settingObject.logLevel, "PopulateData.populateProdData",
          "data population process (id:$genericId) error during populateProdData ${eError.toString()} with stack trace ${sTackTrace.toString()}");
    }
  }
}
