import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:developer';

import 'package:prodeye/models/notification.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/widgets/base_renderer.dart';
import 'package:prodeye/widgets/common.dart';
import 'package:prodeye/common_utils/query_key.dart';
import 'package:prodeye/providers/notification_provider.dart';
import 'package:prodeye/providers/notification_entry_provider.dart';

class NotificationRow extends StatefulWidget {
  const NotificationRow({super.key});
  @override
  State<NotificationRow> createState() => _NotificationRow();
}

class _NotificationRow extends State<NotificationRow> with BaseStateRenderer {
  @override
  Widget realBuild(BuildContext context) {
    PordiNotificationProvider notesProvider =
        Provider.of<PordiNotificationProvider>(context);
    PordiNotificationEntryProvider myNoteProvider =
        Provider.of<PordiNotificationEntryProvider>(context);

    ProdiNotification notif = myNoteProvider.notif;

    List<String> titleSubtitle = notif.title.split("^");
    String titleText =
        titleSubtitle.length == 3 ? titleSubtitle[2] : notif.title;
    String subtitleText = titleSubtitle.length == 3
        ? "${titleSubtitle[0]} - ${titleSubtitle[1]}"
        : "\"\"";

    Widget retBuild = Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 2.5,
        color: notif.shown ? Colors.white : Colors.lightBlueAccent,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(8.0),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "$titleText received at ${formatDate(QueryKey.getDateTimeFromQueryKey(notif.qKey.toString()).toLocal())}"),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(subtitleText),
          ),
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(notif.body),
              ),
            ])
          ],
          onExpansionChanged: (value) async {
            if (value && !notif.shown) {
              await myNoteProvider.updateAsShown();
              await notesProvider.loadList();

              setState(() {});
            }
          },
        ));

    return retBuild;
  }

  @override
  Widget build(BuildContext context) {
    settingObject = Provider.of<ProdiSettings>(context).settingObject;

    return super.build(context);
  }
}
