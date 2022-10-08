import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:prodeye/models/profile.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/query_managers/component_job.dart';
import 'package:prodeye/query_managers/component_log.dart';
import 'package:prodeye/query_managers/component_queue_and_messages.dart';
import 'package:prodeye/query_managers/production.dart';
import 'package:prodeye/common_utils/query_key.dart';
import 'package:prodeye/providers/profile_entry.dart';

class ProfileProvider with ChangeNotifier {
  List<Profile> listOfProfiles = [];
  List<ProfileEntryProvider> listOfProfileProviders = [];
  late Timer timer;
  bool timerIsUp = false;
  bool _locked = false;
  set locked(bool lck) {
    _locked = lck;
    notifyListeners();
  }

  bool get locked {
    return _locked;
  }

  Future<void> buildProfileList() async {
    locked = true;
    List<dynamic> listOfDynamicProfiles =
        await Profile.KVStoreHook.readAllRecords("Profile");

    listOfProfiles = listOfDynamicProfiles
        .map((e) => Profile.fromJson(json.decode(e)))
        .toList();
    listOfProfileProviders = [];
    for (var prof in listOfProfiles) {
      prof.productionObjects = ProductionQuery(prof.id);
      listOfProfileProviders.add(ProfileEntryProvider(currentProfile: prof));
    }

    notifyListeners();
    locked = false;
  }

  void buildProfileListAndSetTimer({int secondCnt = 10}) async {
    ProdEyeSettings settings = await ProdEyeSettings.getSettings();
    secondCnt = settings.screenDataRefreshIntervalSeconds > 0
        ? settings.screenDataRefreshIntervalSeconds
        : secondCnt;
    await buildProfileList();
    timer = Timer.periodic(Duration(seconds: secondCnt), (timer) async {
      if (!locked) {
        await buildProfileList();
      }
    });
    timerIsUp = true;
  }

  Future<void> loadDataByDateTimeFrame(
      DateTime datefrom, DateTime dateto) async {
    await buildProfileList();
    int datefromQKey = int.parse(QueryKey.getQueryKeyFromDateTime(datefrom));
    int datetoQKey = int.parse(QueryKey.getQueryKeyFromDateTime(dateto));
    for (var profile in listOfProfiles) {
      await profile.productionObjects.prepare(profile);
      for (var prod in profile.productionObjects.productions) {
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
}
