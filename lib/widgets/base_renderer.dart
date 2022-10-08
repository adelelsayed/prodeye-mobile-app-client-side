import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/widgets/error_widget.dart';
import 'package:prodeye/models/settings.dart';

class BaseStateRenderer {
  late ProdEyeSettings settingObject;

  realBuild(BuildContext context) {}

  Widget build(BuildContext context) {
    ProdiLog.debug(
        settingObject.logLevel,
        "${this.runtimeType.toString()} build",
        "starting build of ${this.runtimeType.toString()}");

    try {
      Widget retVal = this.realBuild(context);

      ProdiLog.debug(
          settingObject.logLevel,
          "${this.runtimeType.toString()} build",
          "ending build of ${this.runtimeType.toString()}");

      return retVal;
    } catch (eError, sTackTrace) {
      ProdiLog.error(settingObject.logLevel, this.runtimeType.toString(),
          "error in ${this.runtimeType.toString()} ${eError.toString()}",
          stackTrace: sTackTrace.toString());

      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ProdiErrorWidget(
            MessageOfError:
                "Error During Displaying ${this.runtimeType.toString()} widget"),
      );
    }
  }
}
