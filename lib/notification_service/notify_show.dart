import 'dart:developer';

import 'package:prodeye/models/notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prodeye/notification_service/notify_plugin_interface.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/logger/logger_utils.dart';

Future<void> showNotifications() async {
  ProdEyeSettings settingObject = await ProdEyeSettings.getSettings();

  int genericId = DateTime.now().millisecondsSinceEpoch;

  ProdiLog.debug(settingObject.logLevel, "showNotifications",
      "showNotifications process (id:$genericId) started");
  try {
    //get instance of plugin
    ProdiLog.debug(settingObject.logLevel, "showNotifications",
        "showNotifications process (id:$genericId) plugin initialized");

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        await getNotificationReadyPlugin();

    final NotificationDetails notifDetails = getNotificationDetails();

    //query non shown notifications
    ProdiLog.debug(settingObject.logLevel, "showNotifications",
        "showNotifications process (id:$genericId) querying non shown notifications");

    List<Map<String, Object?>> querySet =
        await ProdiNotification.query("shown", "=", "0");

    List<ProdiNotification> notifList =
        querySet.map((note) => ProdiNotification.fromQueryMap(note)).toList();

    ProdiLog.debug(settingObject.logLevel, "showNotifications",
        "showNotifications process (id:$genericId) picked up notifications ${querySet.toString()} and built them into ProdiNotifications and starting sending them via the plugin to user in a loop");

    for (var noti in notifList) {
      await noti.show(flutterLocalNotificationsPlugin, notifDetails);
    }
  } catch (eError, sTackTrace) {
    ProdiLog.error(settingObject.logLevel, "showNotifications",
        "showNotifications process (id:$genericId)  error during query And Notify ${eError.toString()}",
        stackTrace: sTackTrace.toString());
  }
}
