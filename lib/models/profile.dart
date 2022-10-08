import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:prodeye/models/utils.dart';
import 'package:prodeye/storage_apis/kv_store.dart';
import 'package:prodeye/query_managers/production.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/logger/logger_levels.dart';
import 'package:prodeye/query_managers/component_job.dart';
import 'package:prodeye/query_managers/component_log.dart';
import 'package:prodeye/query_managers/component_queue_and_messages.dart';
import 'package:prodeye/http_tools/http_interface.dart';
import 'package:prodeye/common_utils/query_key.dart';

class Profile {
  String id = "";
  String name;
  String url;
  String username;
  String password;
  int dataBackgroundSync = 1;
  int dataBackgroundSyncIntervalMinutes = 5;
  String lastQueriedKey = "";
  int cacheDays = 30;
  ProdiAuthenticationTypes authMode = ProdiAuthenticationTypes.Basic;
  String authUrl = "";
  String token = "";
  String tokeExpiry = "";
  static KVStore KVStoreHook = KVStore();
  late ProductionQuery productionObjects;

  Profile(
      {required this.name,
      required this.url,
      required this.username,
      required this.password}) {
    id = id == "" ? const Uuid().v5(Uuid.NAMESPACE_URL, url) : id;
    productionObjects = ProductionQuery(id);
  }

  factory Profile.fromJson(var recordJson) {
    Map<String, dynamic> recordMap = Map<String, dynamic>.from(recordJson);

    Profile profile = Profile(
        name: recordMap["name"],
        url: recordMap["url"],
        username: recordMap["username"],
        password: recordMap["password"]);
    profile.id = recordMap["id"];
    profile.dataBackgroundSync = recordMap["dataBackgroundSync"];
    profile.dataBackgroundSyncIntervalMinutes =
        recordMap["dataBackgroundSyncIntervalMinutes"];
    profile.lastQueriedKey = recordMap["lastQueriedKey"];
    profile.cacheDays = int.tryParse(recordMap["cacheDays"].toString()) ?? 30;
    profile.authMode = recordMap.containsKey("authMode")
        ? ProdiAuthenticationTypes.values
            .where(
                (element) => element.name == recordMap["authMode"].toString())
            .first
        : ProdiAuthenticationTypes.Basic;
    profile.authUrl = recordMap["authUrl"];
    profile.token = recordMap["token"];
    profile.tokeExpiry = recordMap["tokeExpiry"];

    return profile;
  }

  String inToJson() {
    Map<String, dynamic> profileMap = {
      "id": id,
      "name": name,
      "url": url,
      "username": username,
      "password": password,
      "dataBackgroundSync": dataBackgroundSync,
      "dataBackgroundSyncIntervalMinutes": dataBackgroundSyncIntervalMinutes,
      "lastQueriedKey": lastQueriedKey,
      "cacheDays": cacheDays,
      "authMode": authMode.name,
      "authUrl": authUrl,
      "token": token,
      "tokeExpiry": tokeExpiry
    };
    return json.encode(profileMap);
  }

  String getAuth() {
    if (authMode == ProdiAuthenticationTypes.Basic) {
      return "${authMode.name} ${base64.encode(utf8.encode("$username:$password"))}";
    } else if (authMode == ProdiAuthenticationTypes.Token) {
      if (token.isNotEmpty &&
          tokeExpiry.isNotEmpty &&
          DateTime.tryParse(tokeExpiry) is DateTime &&
          DateTime.tryParse(tokeExpiry)!.toLocal().isAfter(DateTime.now())) {
        return "${authMode.name} $token";
      } else {
        return "";
      }
    } else {
      return "";
    }
  }

  Future<void> setAuth() async {
    if (authMode == ProdiAuthenticationTypes.Token &&
        authUrl.isNotEmpty &&
        (tokeExpiry.isEmpty ||
            (tokeExpiry.isNotEmpty &&
                DateTime.tryParse(tokeExpiry) is DateTime &&
                DateTime.tryParse(tokeExpiry)!
                    .toLocal()
                    .isBefore(DateTime.now())))) {
      PIHttp authRequest = PIHttp(
          Uri.parse(authUrl), {"username": username, "password": password},
          (dataResponse) async {
        if (dataResponse.statusCode == 200) {
          Map<String, dynamic> dataMap =
              Map<String, dynamic>.from(json.decode(dataResponse.body));

          String newToken = dataMap["Token"].toString();
          String newTokeExpiry = dataMap["Expiry"].toString();
          if (newToken.isNotEmpty &&
              newTokeExpiry.isNotEmpty &&
              DateTime.tryParse(newTokeExpiry) is DateTime) {
            token = newToken;
            tokeExpiry = newTokeExpiry;
            await Profile.KVStoreHook.writeRecord(this);
          } else {
            throw Exception(
                "Authentication request response invalid for profile $name with http code ${dataResponse.statusCode} with reason code ${dataResponse.reasonPhrase} with server message ${dataResponse.body.toString()}");
          }
        } else {
          throw Exception(
              "Authentication request failed for profile $name with http code ${dataResponse.statusCode} with reason code ${dataResponse.reasonPhrase} with server message ${dataResponse.body.toString()}");
        }
      });
      await authRequest.get().onError((error, stackTrace) {
        ProdiLog.error(ProdiLogLevels.error, "setAuth",
            "error during Authentication request ${error.toString()}",
            stackTrace: stackTrace.toString());
      });
    }
  }

  Future<void> loadDataByDateTimeFrame(
      DateTime datefrom, DateTime dateto) async {
    int datefromQKey = int.parse(QueryKey.getQueryKeyFromDateTime(datefrom));
    int datetoQKey = int.parse(QueryKey.getQueryKeyFromDateTime(dateto));

    productionObjects = ProductionQuery(id);

    await productionObjects.prepare(this);

    for (var prod in productionObjects.productions) {
      //await prod.components.prepare(prod);
      for (var comp in prod.components.components) {
        comp.queMessages = ComponentQueueMessageStatsQuery(
            comp.id.toString(), [datefromQKey, datetoQKey]);

        await comp.queMessages.prepare(comp);
        comp.jobs =
            ComponentJobQuery(comp.id.toString(), [datefromQKey, datetoQKey]);
        await comp.jobs.prepare(comp);
        comp.errors =
            ComponentErrors(comp.id.toString(), [datefromQKey, datetoQKey]);
        await comp.errors.prepare(comp);
        comp.warnings =
            ComponentWarnings(comp.id.toString(), [datefromQKey, datetoQKey]);

        await comp.warnings.prepare(comp);

        comp.alerts =
            ComponentAlerts(comp.id.toString(), [datefromQKey, datetoQKey]);
        await comp.alerts.prepare(comp);
      }
    }
  }

  Future<void> loadCacheByDateTimeFrame(
      DateTime datefrom, DateTime dateto) async {
    int datefromQKey = int.parse(QueryKey.getQueryKeyFromDateTime(datefrom));
    int datetoQKey = int.parse(QueryKey.getQueryKeyFromDateTime(dateto));

    productionObjects = ProductionQuery(id);

    await productionObjects.prepare(this);

    for (var prod in productionObjects.productions) {
      for (var comp in prod.components.components) {
        comp.queMessages = ComponentQueueMessageStatsQuery(
            comp.id.toString(), [datefromQKey, datetoQKey]);

        await comp.queMessages.query(comp, forcedbQuery: true);
        comp.jobs =
            ComponentJobQuery(comp.id.toString(), [datefromQKey, datetoQKey]);
        await comp.jobs.query(comp, forcedbQuery: true);
        comp.errors =
            ComponentErrors(comp.id.toString(), [datefromQKey, datetoQKey]);
        await comp.errors.query(comp, forcedbQuery: true);
        comp.warnings =
            ComponentWarnings(comp.id.toString(), [datefromQKey, datetoQKey]);
        await comp.warnings.query(comp, forcedbQuery: true);
        comp.alerts =
            ComponentAlerts(comp.id.toString(), [datefromQKey, datetoQKey]);
        await comp.alerts.query(comp, forcedbQuery: true);
      }
    }
  }

  Future<void> getCachedDataByDateTimeFrame(
      DateTime datefrom, DateTime dateto) async {
    int datefromQKey = int.parse(QueryKey.getQueryKeyFromDateTime(datefrom));
    int datetoQKey = int.parse(QueryKey.getQueryKeyFromDateTime(dateto));

    productionObjects = ProductionQuery(id);

    await productionObjects.prepare(this);

    for (var prod in productionObjects.productions) {
      //await prod.components.prepare(prod);
      for (var comp in prod.components.components) {
        comp.queMessages = ComponentQueueMessageStatsQuery(
            comp.id.toString(), [datefromQKey, datetoQKey]);

        await comp.queMessages.prepare(comp);
        comp.jobs =
            ComponentJobQuery(comp.id.toString(), [datefromQKey, datetoQKey]);
        await comp.jobs.prepare(comp);
        comp.errors =
            ComponentErrors(comp.id.toString(), [datefromQKey, datetoQKey]);
        await comp.errors.prepare(comp);
        comp.warnings =
            ComponentWarnings(comp.id.toString(), [datefromQKey, datetoQKey]);
        await comp.warnings.prepare(comp);
        comp.alerts =
            ComponentAlerts(comp.id.toString(), [datefromQKey, datetoQKey]);
        await comp.alerts.prepare(comp);
      }
    }
  }
}
