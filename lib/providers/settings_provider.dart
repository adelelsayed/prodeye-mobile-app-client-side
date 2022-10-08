import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:developer';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/logger/logger_levels.dart';

class ProdiSettings with ChangeNotifier {
  ProdEyeSettings settingObject = ProdEyeSettings(
      logLevel: ProdiLogLevels.error,
      supportEmail: "",
      internalCacheServicePort: 6772,
      screenDataRefreshIntervalSeconds: 10,
      dataTaskIntervalMinutes: 1,
      cacheTaskIntervalMinutes: 5);
  Future<void> loadsettingObject() async {
    settingObject = await ProdEyeSettings.getSettings();

    notifyListeners();
  }

  void loadsettingObjectAndSetTimer(int secondCnt) async {
    await loadsettingObject();
    Timer.periodic(Duration(seconds: secondCnt), (timer) async {
      await loadsettingObject();
    });
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
