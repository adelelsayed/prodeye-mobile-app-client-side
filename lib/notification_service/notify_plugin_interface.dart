import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:prodeye/views/notification_list.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prodeye/main.dart';

Future<void> selectNotification(String? payload) async {
  //Handle notification tapped logic here
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? details) {}

Future<FlutterLocalNotificationsPlugin> getNotificationReadyPlugin() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('neweye');

  const IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: null);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);

  return flutterLocalNotificationsPlugin;
}

NotificationDetails getNotificationDetails() {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails("prodeye", "prodeye",
          channelDescription: "prodeye",
          importance: Importance.max,
          priority: Priority.max);

  const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails(
          presentAlert:
              true, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
          presentBadge:
              true, // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
          presentSound:
              true, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
          sound:
              "", // Specifics the file path to play (only from iOS 10 onwards)
          badgeNumber: 1, // The application's icon badge number
          subtitle:
              "prodeye", //Secondary description  (only from iOS 10 onwards)
          threadIdentifier: "prodeye");

  const NotificationDetails notifDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  return notifDetails;
}
