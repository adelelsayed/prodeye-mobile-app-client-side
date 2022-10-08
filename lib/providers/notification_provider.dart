import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:prodeye/common_utils/query_key.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/models/notification.dart';

class PordiNotificationProvider with ChangeNotifier {
  List<ProdiNotification> listOfNotifs = [];
  late Timer timer;
  bool timerIsUp = false;
  Future<void> loadList({int pQKey = 0}) async {
    pQKey = pQKey == 0
        ? int.parse(QueryKey.getQueryKeyFromDateTime(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day - 7)))
        : pQKey;

    List<Map<String, Object?>> rawListOfNotifs =
        await ProdiNotification.query("qKey", ">", pQKey);
    listOfNotifs = rawListOfNotifs
        .map((notifMap) => ProdiNotification.fromQueryMap(notifMap))
        .toList();
    listOfNotifs.sort((a, b) => b.ID.compareTo(a.ID));
    notifyListeners();
  }

  void loadNotifListAndSetTimer({int secondCnt = 10}) async {
    ProdEyeSettings settings = await ProdEyeSettings.getSettings();
    secondCnt = settings.screenDataRefreshIntervalSeconds > 0
        ? settings.screenDataRefreshIntervalSeconds
        : secondCnt;
    await loadList();
    timer = Timer.periodic(Duration(seconds: secondCnt), (timer) async {
      await loadList();
    });
    timerIsUp = true;
  }

  bool _locked = false;
  set locked(bool lck) {
    _locked = lck;
    notifyListeners();
  }

  bool get locked {
    return _locked;
  }
}
