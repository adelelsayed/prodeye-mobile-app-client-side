import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/widgets/data_purge.dart';
import 'package:prodeye/widgets/error_widget.dart';

class DataPurgeView extends StatelessWidget {
  static String routeName = "DataPurgeView";
  const DataPurgeView({super.key});
  @override
  Widget build(BuildContext context) {
    ProdEyeSettings settingObj =
        Provider.of<ProdiSettings>(context).settingObject;

    ProdiLog.debug(settingObj.logLevel, "${this.runtimeType.toString()} build",
        "starting build of ${this.runtimeType.toString()}");
    Size screenSize = MediaQuery.of(context).size;

    try {
      var retVal = SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: DataPurge());

      ProdiLog.debug(
          settingObj.logLevel,
          "${this.runtimeType.toString()} build",
          "ending build of ${this.runtimeType.toString()}");

      return retVal;
    } catch (eError, sTackTrace) {
      ProdiLog.error(
          settingObj.logLevel, "DataPurgeView", "error in DataPurgeView",
          stackTrace: sTackTrace.toString());

      return ProdiErrorWidget(
          MessageOfError: "Error During Displaying data purge widget");
    }
  }
}
