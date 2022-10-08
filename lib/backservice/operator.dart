import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/notification_service/notify_populate.dart';
import 'package:prodeye/notification_service/notify_show.dart';
import 'package:prodeye/data_service/data_fetch.dart';
import 'package:prodeye/data_service/data_cache.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/logger/logger_levels.dart';

dynamic operator(ServiceInstance _instance) async {
  try {
    ProdEyeSettings settingsObj = await ProdEyeSettings.getSettings();
//register timed workers
    int minutesForData = settingsObj.dataTaskIntervalMinutes > 0
        ? settingsObj.dataTaskIntervalMinutes
        : 1;
    int minutesForCache = settingsObj.cacheTaskIntervalMinutes > 0
        ? settingsObj.cacheTaskIntervalMinutes
        : 5;

    Timer.periodic(Duration(minutes: minutesForData), (timer) async {
      await fetchData();
      await logNotifs();
      await showNotifications();
    });

    Timer.periodic(Duration(minutes: minutesForCache), (timer) async {
      await ProfileDataCache.queryAndCache();
    });

//start web server for data cache

    var server = await HttpServer.bind(
        InternetAddress.loopbackIPv4, settingsObj.internalCacheServicePort);

    await for (HttpRequest request in server) {
      if (request.headers.value('host').toString() ==
          "${InternetAddress.loopbackIPv4.address.toString()}:${settingsObj.internalCacheServicePort.toString()}") {
        int prodId = int.parse(request.headers.value("prodId").toString());
        int compId = int.parse(request.headers.value("compId").toString());
        String dataKey = request.headers.value("dataKey").toString();
        int from = int.parse(request.headers.value("from").toString());
        int to = int.parse(request.headers.value("to").toString());

        Map<String, List<Map<String, dynamic>>> retVal =
            ProfileDataCache.getCacheByQkeyRange(
                prodId, compId, dataKey, from, to);

        request.response.write(json.encode(retVal));
        await request.response.close();
      } else {
        await request.response.close();
      }
    }

    //_instance.on('update').listen((event) {  });
  } catch (error, stak) {
    ProdiLog.error(ProdiLogLevels.error, "operator",
        "error during running operator ${error.toString()}",
        stackTrace: stak.toString());
  }
}

Future<bool> iosBackgroundOperator(ServiceInstance _instance) async {
  await operator(_instance);
  return true;
}

///central back service operation
Future<void> initOperator() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: operator,

        // auto start service
        autoStart: true,
        isForegroundMode: true,
        foregroundServiceNotificationContent: "ProdEye Working",
        foregroundServiceNotificationTitle: "ProdEye"),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: operator,

      // you have to enable background fetch capability on xcode project
      onBackground: iosBackgroundOperator,
    ),
  );
  service.startService();
}
