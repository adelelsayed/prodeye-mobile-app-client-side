import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:prodeye/providers/notification_provider.dart';
import 'package:prodeye/providers/notification_entry_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:prodeye/models/notification.dart';
import 'package:prodeye/widgets/error_widget.dart';
import 'package:prodeye/widgets/notification_row.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/models/settings.dart';

class NotificationListView extends StatefulWidget {
  static String routeName = "NotificationListView";
  const NotificationListView({super.key});

  @override
  State<NotificationListView> createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<NotificationListView> {
  @override
  Widget build(BuildContext context) {
    ProdEyeSettings settingObj =
        Provider.of<ProdiSettings>(context).settingObject;
    PordiNotificationProvider myNoteProvider =
        Provider.of<PordiNotificationProvider>(context);
    List<ProdiNotification> notifs = myNoteProvider.listOfNotifs;

    ProdiLog.debug(settingObj.logLevel, "${this.runtimeType.toString()} build",
        "starting build of ${this.runtimeType.toString()}");
    Size screenSize = MediaQuery.of(context).size;

    try {
      var retVal = Scaffold(
        appBar: AppBar(
          title: GestureDetector(child: const Text("Prodi"), onTap: () {}),
        ),
        body: SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: ListView.builder(
            itemBuilder: (ctx, idx) {
              return ChangeNotifierProvider.value(
                  value: PordiNotificationEntryProvider(notif: notifs[idx]),
                  child: const NotificationRow());
            },
            itemCount: notifs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
          ),
        ),
      );

      ProdiLog.debug(
          settingObj.logLevel,
          "${this.runtimeType.toString()} build",
          "ending build of ${this.runtimeType.toString()}");

      return retVal;
    } catch (eError, sTackTrace) {
      ProdiLog.error(settingObj.logLevel, "NotificationListView",
          "error in NotificationListView ${eError.toString()}",
          stackTrace: sTackTrace.toString());
      Navigator.of(context).pop();

      return ProdiErrorWidget(
          MessageOfError: "Error During Displaying Notification List widget");
    }
  }
}
