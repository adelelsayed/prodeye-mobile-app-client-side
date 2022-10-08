import 'package:flutter/material.dart';
import 'package:prodeye/models/production.dart';
import 'package:provider/provider.dart';

import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/widgets/error_widget.dart';
import 'package:prodeye/widgets/production_settings.dart';

class ProductionSettingsView extends StatelessWidget {
  static String routeName = "ProductionSettings";

  const ProductionSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    ProdEyeSettings settingObj =
        Provider.of<ProdiSettings>(context).settingObject;
    Production prod = ModalRoute.of(context)!.settings.arguments as Production;

    ProdiLog.debug(settingObj.logLevel, "${this.runtimeType.toString()} build",
        "starting build of ${this.runtimeType.toString()}");
    Size screenSize = MediaQuery.of(context).size;
    try {
      var retVal = SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: ProductionSettings(prod: prod));

      ProdiLog.debug(
          settingObj.logLevel,
          "${this.runtimeType.toString()} build",
          "ending build of ${this.runtimeType.toString()}");

      return retVal;
    } catch (eError, sTackTrace) {
      ProdiLog.error(settingObj.logLevel, "ProductionSettingsView",
          "error in ProductionSettingsView",
          stackTrace: sTackTrace.toString());

      return ProdiErrorWidget(
          MessageOfError: "Error During Displaying Production Settings widget");
    }
  }
}
