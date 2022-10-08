import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:prodeye/widgets/profile_detail.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/widgets/error_widget.dart';

class ProfileDetailView extends StatelessWidget {
  static String routeName = "ProfileDetail";

  const ProfileDetailView({super.key});
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
          child: ProfileDetail());

      ProdiLog.debug(
          settingObj.logLevel,
          "${this.runtimeType.toString()} build",
          "ending build of ${this.runtimeType.toString()}");

      return retVal;
    } catch (eError, sTackTrace) {
      ProdiLog.error(settingObj.logLevel, "ProfileDetailView",
          "error in ProfileDetailView",
          stackTrace: sTackTrace.toString());

      return ProdiErrorWidget(
          MessageOfError: "Error During Displaying Profile edit widget");
    }
  }
}
