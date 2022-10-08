import 'dart:developer';
import 'dart:async';
import 'package:prodeye/http_tools/http_interface.dart';
import 'package:prodeye/models/profile.dart';
import 'dart:convert';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/data_service/data_populate.dart';
import 'package:prodeye/common_utils/query_key.dart';
import 'package:prodeye/models/settings.dart';

dynamic fetchData() async {
  ProdEyeSettings settingObject = await ProdEyeSettings.getSettings();

  int genericId = DateTime.now().millisecondsSinceEpoch;
  ProdiLog.debug(settingObject.logLevel, "fetchData",
      "data fetch process (id:$genericId) started");

  try {
    DateTime now = DateTime.now().toUtc();
    List<dynamic> listOfDynamicProfiles =
        await Profile.KVStoreHook.readAllRecords("Profile");
    List<Profile> listOfProfiles = listOfDynamicProfiles
        .map((e) => Profile.fromJson(json.decode(e)))
        .toList();

    ProdiLog.debug(settingObject.logLevel, "fetchData",
        "data fetch process (id:$genericId) picked up profiles ${listOfDynamicProfiles.toString()}");

    for (Profile profile in listOfProfiles) {
      ProdiLog.debug(settingObject.logLevel, "fetchData",
          "data fetch process (id:$genericId) started running for ${profile.name}");

      if ((profile.dataBackgroundSync == 0) ||
          ((profile.lastQueriedKey.isNotEmpty) &&
              (profile.lastQueriedKey != 0) &&
              (now.difference(QueryKey.getDateTimeFromQueryKey(
                          profile.lastQueriedKey)))
                      .inMinutes <
                  profile.dataBackgroundSyncIntervalMinutes)) {
        continue;
      }

      ProdiLog.debug(settingObject.logLevel, "fetchData",
          "data fetch process (id:$genericId) authenticating for ${profile.name}");

      await profile.setAuth();
      String auth = profile.getAuth();
      if (auth.isEmpty) {
        throw Exception("profile ${profile.name} Authorisation is empty");
      }
      String requestQueryKey =
          profile.lastQueriedKey.isNotEmpty && profile.lastQueriedKey != "0"
              ? profile.lastQueriedKey
              : QueryKey.getQueryKeyFromDateTime(
                  DateTime(now.year, now.month, now.day).toLocal());

      PIHttp dataRequest = PIHttp(Uri.parse(profile.url), {
        "cutoff": requestQueryKey,
        "profilename": profile.name,
        "Authorisation": auth
      }, (dataResponse) async {
        if (dataResponse.statusCode == 200) {
          Map<String, dynamic> dataMap =
              Map<String, dynamic>.from(json.decode(dataResponse.body));

          ProdiLog.debug(settingObject.logLevel, "fetchData",
              "fetchData request sent with querykey $requestQueryKey and response is ${dataMap.toString()}");
          await PopulateData.populateProdData(dataMap, profile);
          String nextKey = dataMap["Next"].toString();
          profile.lastQueriedKey = nextKey.isNotEmpty && nextKey != "0"
              ? nextKey
              : QueryKey.getQueryKeyFromDateTime(DateTime.now());

          await Profile.KVStoreHook.writeRecord(profile);
        } else {
          throw Exception(
              "data request failed for profile ${profile.name} with http code ${dataResponse.statusCode} with reason code ${dataResponse.reasonPhrase} with server message ${dataResponse.body.toString()}");
        }
      });

      ProdiLog.debug(settingObject.logLevel, "fetchData",
          "data fetch process (id:$genericId) posting for ${profile.name} with queryKey $requestQueryKey");

      dataRequest.post().onError((error, stackTrace) {
        ProdiLog.error(settingObject.logLevel, "fetchData",
            "data fetch process (id:$genericId) error during fetch Data ${error.toString()}",
            stackTrace: stackTrace.toString());
      });
    }
  } catch (eError, sTackTrace) {
    ProdiLog.error(settingObject.logLevel, "fetchData",
        "data fetch process (id:$genericId) error during fetch Data ${eError.toString()}",
        stackTrace: sTackTrace.toString());
  }
}
