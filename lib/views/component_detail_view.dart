import 'package:flutter/material.dart';
import 'package:prodeye/models/component.dart';
import 'package:prodeye/widgets/component_stats.dart';
import 'package:prodeye/widgets/component_log.dart';
import 'package:provider/provider.dart';

import 'dart:developer';

import 'package:prodeye/widgets/error_widget.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/widgets/common.dart';

class ComponentDetailView extends StatelessWidget {
  static String routeName = "ComponentDetailView";
  const ComponentDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    componentDetailRouteArguments routeArgs = ModalRoute.of(context)!
        .settings
        .arguments as componentDetailRouteArguments;
    Component myComponent = routeArgs.comp;
    ProdEyeSettings settingObj =
        Provider.of<ProdiSettings>(context).settingObject;

    bool componentDisplayChart = routeArgs.displayChart;

    ProdiLog.debug(settingObj.logLevel, "${this.runtimeType.toString()} build",
        "starting build of ${this.runtimeType.toString()}");
    Size screenSize = MediaQuery.of(context).size;
    try {
      var retVal = Scaffold(
        appBar: AppBar(
          title: GestureDetector(child: Text(myComponent.name), onTap: () {}),
        ),
        body: SingleChildScrollView(
            child: componentDisplayChart
                ? SizedBox(
                    height: screenSize.height,
                    width: screenSize.width,
                    child: ComponentStatsDisplay(myComponent: myComponent))
                : SizedBox(
                    height: screenSize.height,
                    width: screenSize.width,
                    child: ComponentLogDisplay(myComponent: myComponent))),
      );
      ProdiLog.debug(
          settingObj.logLevel,
          "${this.runtimeType.toString()} build",
          "ending build of ${this.runtimeType.toString()}");
      return retVal;
    } catch (eError, sTackTrace) {
      ProdiLog.error(settingObj.logLevel, "Component Detail View",
          "error in ComponentDetailView ${eError.toString()}",
          stackTrace: sTackTrace.toString());
      Navigator.of(context).pop();

      return ProdiErrorWidget(
          MessageOfError: "Error During Displaying Component Detail widget");
    }
  }
}
