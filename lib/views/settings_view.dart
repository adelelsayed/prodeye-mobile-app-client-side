import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/widgets/log_level.dart';
import 'package:prodeye/widgets/error_widget.dart';
import 'package:prodeye/widgets/settings_widget.dart';

class SettingsView extends StatelessWidget {
  static String routeName = "SettingsView";
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    ProdEyeSettings settingObj =
        Provider.of<ProdiSettings>(context).settingObject;

    ProdiLog.debug(settingObj.logLevel, "${this.runtimeType.toString()} build",
        "starting build of ${this.runtimeType.toString()}");
    Size screenSize = MediaQuery.of(context).size;
    try {
      var retVal = Scaffold(
          appBar: AppBar(
            title: GestureDetector(
                child: const Text("Prodi"),
                onTap: () {
                  //Navigator.of(context).pushReplacementNamed(ProfileListView.routeName);
                }),
          ),
          body: SizedBox(
            height: screenSize.height,
            width: screenSize.width,
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: screenSize.height * 0.2,
                        width: screenSize.width,
                        child: LogLevel()),
                    SizedBox(
                        height: screenSize.height * 0.7,
                        width: screenSize.width,
                        child: SettingsEditWidget())
                  ]),
            ),
          ));

      ProdiLog.debug(
          settingObj.logLevel,
          "${this.runtimeType.toString()} build",
          "ending build of ${this.runtimeType.toString()}");

      return retVal;
    } catch (eError, sTackTrace) {
      ProdiLog.error(
          settingObj.logLevel, "SettingsView", "error in SettingsView",
          stackTrace: sTackTrace.toString());

      return ProdiErrorWidget(
          MessageOfError: "Error During Displaying Settings edit widget");
    }
  }
}
