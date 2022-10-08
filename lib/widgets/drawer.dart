import 'package:flutter/material.dart';
import 'package:prodeye/views/data_purge_view.dart';

import 'package:prodeye/views/settings_view.dart';
import 'package:prodeye/widgets/error_widget.dart';
import 'package:prodeye/views/notification_list.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:prodeye/widgets/base_renderer.dart';

class ProdiDrawer extends StatelessWidget with BaseStateRenderer {
  @override
  Widget realBuild(BuildContext context) {
    return Drawer(
        child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
          const SizedBox(
            height: 80,
            child: DrawerHeader(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: Color(0xFF272F7A),
              ),
              child: Text('Prodi'),
            ),
          ),
          ListTile(
            title: const Text('Setting'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(SettingsView.routeName);
            },
          ),
          ListTile(
              title: const Text('Support'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => ProdiErrorWidget(
                          MessageOfError: "",
                        )));
              }),
          ListTile(
              title: const Text('Data Purge'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(DataPurgeView.routeName);
              })
        ]));
  }

  @override
  Widget build(BuildContext context) {
    settingObject = Provider.of<ProdiSettings>(context).settingObject;

    return super.build(context);
  }
}
