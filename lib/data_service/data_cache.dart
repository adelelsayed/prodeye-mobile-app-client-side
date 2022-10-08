import 'dart:convert';
import 'dart:developer';

import 'package:prodeye/models/profile.dart';
import 'package:prodeye/models/production.dart';
import 'package:prodeye/models/component.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/logger/logger_levels.dart';
import 'package:prodeye/models/settings.dart';

class ProfileDataCache {
  static DateTime lastCacheDateTime = DateTime(2022, 9, 1);

  ///{productionId:{componentId:{dataKey (i.e: jobs):[list of qkeys]}}}
  static Map<int, Map<int, Map<String, List<int>>>> cacheQkeys = {};

  ///{productionId:{componentId:{dataKey (i.e: jobs):{qkey:[{object1},{object2},{object3},..]}}}}
  static Map<int, Map<int, Map<String, Map<int, List<Map<String, dynamic>>>>>>
      cacheByQkey = {};

  static Future<void> queryAndCache() async {
    ProdEyeSettings settingObject = await ProdEyeSettings.getSettings();

    int genericId = DateTime.now().millisecondsSinceEpoch;

    ProdiLog.debug(settingObject.logLevel, "ProfileDataCache.queryAndCache",
        "cache process (id:$genericId) started");
    try {
      List<dynamic> listOfDynamicProfiles =
          await Profile.KVStoreHook.readAllRecords("Profile");
      List<Profile> listOfProfiles = listOfDynamicProfiles
          .map((e) => Profile.fromJson(json.decode(e)))
          .toList();
      Profile.KVStoreHook.readAllRecords('Profile');

      for (Profile profil in listOfProfiles) {
        DateTime dateT = DateTime.now();
        DateTime dateF =
            DateTime(dateT.year, dateT.month, dateT.day - profil.cacheDays);

        ProdiLog.debug(settingObject.logLevel, "ProfileDataCache.queryAndCache",
            "starting caching process (id:$genericId) for ${profil.name} with parameters datefrom ${dateF.toString()} dateto ${dateT.toString()}");

        await profil.loadCacheByDateTimeFrame(dateF, dateT);

        ProdiLog.debug(settingObject.logLevel, "ProfileDataCache.queryAndCache",
            "status update: queries done in caching process (id:$genericId) for ${profil.name} with parameters datefrom ${dateF.toString()} dateto ${dateT.toString()}");

        for (Production prod in profil.productionObjects.productions) {
          cacheQkeys.addAll({prod.id: {}});
          cacheByQkey.addAll({prod.id: {}});

          for (Component comp in prod.components.components) {
            cacheQkeys[prod.id]!.addAll({comp.id: {}});
            cacheByQkey[prod.id]!.addAll({comp.id: {}});
            //queue messages
            String queueMessagesKey = comp.queMessages.runtimeType.toString();
            cacheQkeys[prod.id]![comp.id]!.addAll({
              queueMessagesKey: comp.queMessages.queryMapsList
                  .map((e) => int.parse(e["qKey"].toString()))
                  .toSet()
                  .toList()
            });
            cacheQkeys[prod.id]![comp.id]![queueMessagesKey]!.sort();

            cacheByQkey[prod.id]![comp.id]!.addAll({queueMessagesKey: {}});
            cacheQkeys[prod.id]![comp.id]![queueMessagesKey]!
                .forEach((itmqkey) {
              cacheByQkey[prod.id]![comp.id]![queueMessagesKey]!
                  .addAll({itmqkey: []});
            });

            for (Map<String, Object?> mapItem
                in comp.queMessages.queryMapsList) {
              cacheByQkey[prod.id]![comp.id]![queueMessagesKey]![
                      int.parse(mapItem["qKey"].toString())]!
                  .add(mapItem);
            }

            //jobs
            String jobsKey = comp.jobs.runtimeType.toString();
            cacheQkeys[prod.id]![comp.id]!.addAll({
              jobsKey: comp.jobs.queryMapsList
                  .map((e) => int.parse(e["qKey"].toString()))
                  .toSet()
                  .toList()
            });
            cacheQkeys[prod.id]![comp.id]![jobsKey]!.sort();

            cacheByQkey[prod.id]![comp.id]!.addAll({jobsKey: {}});
            cacheQkeys[prod.id]![comp.id]![jobsKey]!.forEach((itmqkey) {
              cacheByQkey[prod.id]![comp.id]![jobsKey]!.addAll({itmqkey: []});
            });

            for (Map<String, Object?> mapItem in comp.jobs.queryMapsList) {
              cacheByQkey[prod.id]![comp.id]![jobsKey]![
                      int.parse(mapItem["qKey"].toString())]!
                  .add(mapItem);
            }

            //errors
            String errorsKey = comp.errors.runtimeType.toString();
            cacheQkeys[prod.id]![comp.id]!.addAll({
              errorsKey: comp.errors.queryMapsList
                  .map((e) => int.parse(e["qKey"].toString()))
                  .toSet()
                  .toList()
            });
            cacheQkeys[prod.id]![comp.id]![errorsKey]!.sort();
            cacheByQkey[prod.id]![comp.id]!.addAll({errorsKey: {}});

            cacheQkeys[prod.id]![comp.id]![errorsKey]!.forEach((itmqkey) {
              cacheByQkey[prod.id]![comp.id]![errorsKey]!.addAll({itmqkey: []});
            });

            for (Map<String, Object?> mapItem in comp.errors.queryMapsList) {
              cacheByQkey[prod.id]![comp.id]![errorsKey]![
                      int.parse(mapItem["qKey"].toString())]!
                  .add(mapItem);
            }

            //warns
            String warnsKey = comp.warnings.runtimeType.toString();
            cacheQkeys[prod.id]![comp.id]!.addAll({
              warnsKey: comp.warnings.queryMapsList
                  .map((e) => int.parse(e["qKey"].toString()))
                  .toSet()
                  .toList()
            });

            cacheQkeys[prod.id]![comp.id]![warnsKey]!.sort();

            cacheByQkey[prod.id]![comp.id]!.addAll({warnsKey: {}});
            cacheQkeys[prod.id]![comp.id]![warnsKey]!.forEach((itmqkey) {
              cacheByQkey[prod.id]![comp.id]![warnsKey]!.addAll({itmqkey: []});
            });

            for (Map<String, Object?> mapItem in comp.warnings.queryMapsList) {
              cacheByQkey[prod.id]![comp.id]![warnsKey]![
                      int.parse(mapItem["qKey"].toString())]!
                  .add(mapItem);
            }

            //alerts
            String alertsKey = comp.alerts.runtimeType.toString();
            cacheQkeys[prod.id]![comp.id]!.addAll({
              alertsKey: comp.alerts.queryMapsList
                  .map((e) => int.parse(e["qKey"].toString()))
                  .toSet()
                  .toList()
            });
            cacheQkeys[prod.id]![comp.id]![alertsKey]!.sort();

            cacheByQkey[prod.id]![comp.id]!.addAll({alertsKey: {}});
            cacheQkeys[prod.id]![comp.id]![alertsKey]!.forEach((itmqkey) {
              cacheByQkey[prod.id]![comp.id]![alertsKey]!.addAll({itmqkey: []});
            });

            for (Map<String, Object?> mapItem in comp.alerts.queryMapsList) {
              cacheByQkey[prod.id]![comp.id]![alertsKey]![
                      int.parse(mapItem["qKey"].toString())]!
                  .add(mapItem);
            }
          }
        }
        ProdiLog.debug(settingObject.logLevel, "ProfileDataCache.queryAndCache",
            "status update: cache data structure done in caching process (id:$genericId) for ${profil.name} with parameters datefrom ${dateF.toString()} dateto ${dateT.toString()}");
      }
      lastCacheDateTime = DateTime.now();

      ProdiLog.debug(settingObject.logLevel, "ProfileDataCache.queryAndCache",
          "cache process (id:$genericId) ended");
    } catch (error, stak) {
      ProdiLog.error(ProdiLogLevels.error, "ProfileDataCache.queryAndCache",
          "caching process (id:$genericId) error during caching Data ${error.toString()}",
          stackTrace: stak.toString());
    }
  }

  static Map<String, List<Map<String, dynamic>>> getCacheByQkeyRange(
      int prodId, int compId, String dataKey, int from, int to) {
    List<Map<String, dynamic>> retVal = [];
    int start = from;
    int end = to;

    try {
      List<int> targetQkeys = [];

      if (cacheQkeys.containsKey(prodId) &&
          cacheQkeys[prodId]!.containsKey(compId) &&
          cacheQkeys[prodId]![compId]!.containsKey(dataKey)) {
        targetQkeys = cacheQkeys[prodId]![compId]![dataKey]!
            .where((element) => element >= from && element <= to)
            .toList();
      }

      if (targetQkeys.isEmpty) {
        return {
          "data": [],
          "edges": [
            {
              "start": start,
              "end": end,
              "lastCacheDateTime": lastCacheDateTime.toString()
            }
          ],
        };
      }
      targetQkeys.sort();
      start = targetQkeys.first;
      end = targetQkeys.last;

      for (int ky in targetQkeys) {
        if (cacheByQkey.containsKey(prodId) &&
            cacheByQkey[prodId]!.containsKey(compId) &&
            cacheByQkey[prodId]![compId]!.containsKey(dataKey) &&
            cacheByQkey[prodId]![compId]![dataKey]!.containsKey(ky)) {
          for (Map<String, dynamic> map
              in cacheByQkey[prodId]![compId]![dataKey]![ky]!) {
            retVal.add(map);
          }
        }
      }
    } catch (error, stak) {
      ProdiLog.error(
          ProdiLogLevels.error,
          "ProfileDataCache.getCacheByQkeyRange",
          "error during fetching cached Data, error text: ${error.toString()} , error occured while running this function with parameters productionId $prodId , componentId $compId , dataKey $dataKey from $from to $to",
          stackTrace: stak.toString());
    }
    return {
      "data": retVal,
      "edges": [
        {
          "start": start,
          "end": end,
          "lastCacheDateTime": lastCacheDateTime.toString()
        }
      ],
    };
  }
}
