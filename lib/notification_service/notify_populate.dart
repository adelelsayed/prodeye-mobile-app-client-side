import 'dart:developer';
import 'package:prodeye/models/component.dart';

import 'package:prodeye/common_utils/query_key.dart';
import 'package:prodeye/models/component_queue_and_messages.dart';
import 'dart:convert';
import 'package:prodeye/models/notification.dart';
import 'package:prodeye/models/component_job.dart';
import 'package:prodeye/models/component_log.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/models/profile.dart';
import 'package:prodeye/storage_apis/sql_utils.dart';
import 'package:prodeye/models/production.dart';

Future<void> logNotifs() async {
  ProdEyeSettings settingObject = await ProdEyeSettings.getSettings();

  int genericId = DateTime.now().millisecondsSinceEpoch;

  ProdiLog.debug(settingObject.logLevel, "logNotifs",
      "logNotifications process (id:$genericId) started");
  try {
    List<dynamic> listOfDynamicProfiles =
        await Profile.KVStoreHook.readAllRecords("Profile");
    List<Profile> listOfProfiles = listOfDynamicProfiles
        .map((e) => Profile.fromJson(json.decode(e)))
        .toList();

    ProdiLog.debug(settingObject.logLevel, "logNotifs",
        "logNotifications process (id:$genericId) picked up profiles ${listOfDynamicProfiles.toString()}");

    for (var prof in listOfProfiles) {
      if (prof.lastQueriedKey.isEmpty || prof.lastQueriedKey == 0) {
        continue;
      }

      ProdiLog.debug(settingObject.logLevel, "logNotifs",
          "logNotifications process (id:$genericId) querying data for profile ${prof.name}");
      await prof.loadDataByDateTimeFrame(
          QueryKey.getDateTimeFromQueryKey(
              (int.parse(prof.lastQueriedKey) - 300).toString()),
          DateTime.now().toUtc());

      ProdiLog.debug(settingObject.logLevel, "logNotifs",
          "logNotifications process (id:$genericId) starting logging notification process for queried data of ${prof.name}");

      for (var prod in prof.productionObjects.productions) {
        ProdiLog.debug(settingObject.logLevel, "logNotifs",
            "logNotifications process (id:$genericId) starting logging notification process for queried data of ${prof.name} production ${prod.name}");

        if (prod.showQueueNotification) {
          await logQueue(prod);
        }
        if (prod.showErrorNotification) {
          await logErrors(prod);
        }

        if (prod.showWarningrNotification) {
          await logWarns(prod);
        }

        if (prod.showAlertNotification) {
          await logAlerts(prod);
        }

        if (prod.showJobNotification) {
          await logJobs(prod);
        }
      }
    }
  } catch (eError, sTackTrace) {
    ProdiLog.error(settingObject.logLevel, "logNotifs",
        "logNotifications process (id:$genericId) error during query And Notify ${eError.toString()}",
        stackTrace: sTackTrace.toString());
  }
}

Future<void> logQueue(Production prod) async {
  List<ComponentQueueMessageStats> queMs = prod.components.components
      .where((comp) => comp.queMessages.componentQueueMessageStats.isNotEmpty)
      .toList()
      .map((comp) => comp.queMessages.componentQueueMessageStats)
      .expand((element) => element)
      .toList();

  for (var queM in queMs) {
    List<Map<String, Object?>> existing =
        await ProdiNotification.queryByPropertyList(
            ["prodeyeObjType", "prodeyeObjId"],
            ["=", "="],
            [getSqlString("Queue"), queM.id]);
    if (existing.isNotEmpty) {
      continue;
    }
    if (queM.queueSize == 0) {
      continue;
    }
    ProdiNotification newNote = ProdiNotification(
        title:
            "${prod.profileParent.name}^${prod.name}^${queM.componentParent.name}",
        body:
            "Queue Size of ${queM.queueSize.toString()} at ${QueryKey.getDateTimeFromQueryKey(queM.qKey.toString()).toLocal().toString()}",
        prodeyeObjId: queM.id,
        prodeyeObjType: "Queue",
        qKey: queM.qKey);
    newNote.save();
  }
}

Future<void> logErrors(Production prod) async {
  List<ComponentLog> errors = prod.components.components
      .where((comp) => comp.errors.componentLogs.isNotEmpty)
      .toList()
      .map((comp) => comp.errors.componentLogs)
      .expand((element) => element)
      .toList();

  for (var error in errors) {
    List<Map<String, Object?>> existing =
        await ProdiNotification.queryByPropertyList(
            ["prodeyeObjType", "prodeyeObjId"],
            ["=", "="],
            [getSqlString("Error"), error.id]);
    if (existing.isNotEmpty) {
      continue;
    }
    ProdiNotification newNote = ProdiNotification(
        title:
            "${prod.profileParent.name}^${prod.name}^${error.componentParent.name}",
        body:
            "${error.logMessage} at ${DateTime.parse(error.logTime).toLocal().toString()}",
        prodeyeObjId: error.id,
        prodeyeObjType: "Error",
        qKey: error.qKey);
    newNote.save();
  }
}

Future<void> logWarns(Production prod) async {
  List<ComponentLog> warnings = prod.components.components
      .where((comp) => comp.warnings.componentLogs.isNotEmpty)
      .toList()
      .map((comp) => comp.warnings.componentLogs)
      .expand((element) => element)
      .toList();

  for (var warning in warnings) {
    List<Map<String, Object?>> existing =
        await ProdiNotification.queryByPropertyList(
            ["prodeyeObjType", "prodeyeObjId"],
            ["=", "="],
            [getSqlString("Warning"), warning.id]);
    if (existing.isNotEmpty) {
      continue;
    }
    ProdiNotification newNote = ProdiNotification(
        title:
            "${prod.profileParent.name}^${prod.name}^${warning.componentParent.name}",
        body:
            "${warning.logMessage} at ${DateTime.parse(warning.logTime).toLocal().toString()}",
        prodeyeObjId: warning.id,
        prodeyeObjType: "Warning",
        qKey: warning.qKey);
    newNote.save();
  }
}

Future<void> logAlerts(Production prod) async {
  List<ComponentLog> alerts = prod.components.components
      .where((comp) => comp.alerts.componentLogs.isNotEmpty)
      .toList()
      .map((comp) => comp.alerts.componentLogs)
      .expand((element) => element)
      .toList();
  for (var alert in alerts) {
    List<Map<String, Object?>> existing =
        await ProdiNotification.queryByPropertyList(
            ["prodeyeObjType", "prodeyeObjId"],
            ["=", "="],
            [getSqlString("Alert"), alert.id]);
    if (existing.isNotEmpty) {
      continue;
    }
    ProdiNotification newNote = ProdiNotification(
        title:
            "${prod.profileParent.name}^${prod.name}^${alert.componentParent.name}",
        body:
            "${alert.logMessage} at ${DateTime.parse(alert.logTime).toLocal().toString()}",
        prodeyeObjId: alert.id,
        prodeyeObjType: "Alert",
        qKey: alert.qKey);
    newNote.save();
  }
}

Future<void> logJobs(Production prod) async {
  List<ComponentJob> jobs = prod.components.components
      .where((comp) => comp.jobs.componentJobs.any(
          (job) => !["running", "dequeuing", "Listening"].contains(job.status)))
      .toList()
      .map((comp) => comp.jobs.componentJobs)
      .expand((element) => element)
      .toList();

  for (var job in jobs) {
    List<Map<String, Object?>> existing =
        await ProdiNotification.queryByPropertyList(
            ["prodeyeObjType", "prodeyeObjId"],
            ["=", "="],
            [getSqlString("Job"), job.id]);
    if (existing.isNotEmpty) {
      continue;
    }
    ProdiNotification newNote = ProdiNotification(
        title:
            "${prod.profileParent.name}^${prod.name}^${job.componentParent.name}",
        body: "job ${job.jobId.toString()} found with status ${job.status}",
        prodeyeObjId: job.id,
        prodeyeObjType: "Job",
        qKey: job.qKey);
    newNote.save();
  }
}
