import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:isolate';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:prodeye/backservice/operator.dart';
import 'package:prodeye/providers/profile_provider.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/providers/notification_provider.dart';
import 'package:prodeye/views/profile_view.dart';
import 'package:prodeye/widgets/common.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// init operator starts the background service if not started and establishes the timed operations
  initOperator();

  ///app run framework method call
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ProdiSettings settingObj = ProdiSettings();
    ProfileProvider profiles = ProfileProvider();
    settingObj.loadsettingObject();
    //profiles.buildProfileList();
    profiles.buildProfileListAndSetTimer();

    PordiNotificationProvider notifProvider = PordiNotificationProvider();
    //notifProvider.loadList();
    notifProvider.loadNotifListAndSetTimer();

    var retBuild = MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: profiles),
        ChangeNotifierProvider.value(value: settingObj),
        ChangeNotifierProvider.value(value: notifProvider)
      ],
      child: MaterialApp(
        title: 'Prodi',
        theme: ThemeData(
          primarySwatch: const MaterialColor(0xFF272F7A, <int, Color>{
            50: Color.fromARGB(255, 39, 47, 122),
            100: Color.fromARGB(255, 39, 47, 122),
            200: Color.fromARGB(255, 39, 47, 122),
            300: Color.fromARGB(255, 39, 47, 122),
            400: Color.fromARGB(255, 39, 47, 122),
            500: Color.fromARGB(255, 39, 47, 122),
            600: Color.fromARGB(255, 39, 47, 122),
            700: Color.fromARGB(255, 39, 47, 122),
            800: Color.fromARGB(255, 39, 47, 122),
            900: Color.fromARGB(255, 39, 47, 122)
          }),
        ),
        routes: prodiRoutes,
        home: ProfileListView(),
      ),
    );

    return retBuild;
  }
}
