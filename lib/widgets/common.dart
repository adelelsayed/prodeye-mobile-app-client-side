import 'package:flutter/material.dart';

import 'package:prodeye/views/profile_detail_view.dart';
import 'package:prodeye/views/profile_view.dart';
import 'package:prodeye/views/settings_view.dart';
import 'package:prodeye/views/production_list_view.dart';
import 'package:prodeye/views/production_settings.dart';
import 'package:prodeye/views/data_purge_view.dart';
import 'package:prodeye/views/notification_list.dart';
import 'package:prodeye/views/component_list_view.dart';
import 'package:prodeye/views/component_detail_view.dart';

import 'package:prodeye/models/component.dart';

Map<String, Widget Function(BuildContext)> prodiRoutes = {
  ProfileDetailView.routeName: (context) => const ProfileDetailView(),
  ProfileListView.routeName: (context) => ProfileListView(),
  SettingsView.routeName: (context) => const SettingsView(),
  ProductionListView.routeName: (context) => const ProductionListView(),
  ProductionSettingsView.routeName: (context) => const ProductionSettingsView(),
  DataPurgeView.routeName: (context) => const DataPurgeView(),
  NotificationListView.routeName: (context) => const NotificationListView(),
  ComponentListView.routeName: (context) => const ComponentListView(),
  ComponentDetailView.routeName: (context) => const ComponentDetailView(),
};

// use local date in value
String formatDate(DateTime value) {
  String retVal = "";

  if ((DateTime.now().day - value.day) == 0) {
    retVal =
        "Today ${value.hour.toString().padLeft(2, "0")}:${value.minute.toString().padLeft(2, "0")}";
  } else if (((DateTime.now().day - value.day) == 1) &&
      (DateTime.now().isAfter(value))) {
    retVal =
        "Yesterday ${value.hour.toString().padLeft(2, "0")}:${value.minute.toString().padLeft(2, "0")}";
  } else {
    retVal =
        "${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, "0")}:${value.minute.toString().padLeft(2, "0")}";
  }

  return retVal;
}

class componentDetailRouteArguments {
  Component comp;
  bool displayChart;

  componentDetailRouteArguments(
      {required this.comp, required this.displayChart});
}

TextStyle redStyle = const TextStyle(
    color: Colors.red, shadows: [Shadow(color: Colors.redAccent)]);

TextStyle orangeStyle = const TextStyle(
    color: Colors.orange, shadows: [Shadow(color: Colors.orangeAccent)]);

TextStyle blueStyle = const TextStyle(
    color: Colors.lightBlue, shadows: [Shadow(color: Colors.blueAccent)]);
