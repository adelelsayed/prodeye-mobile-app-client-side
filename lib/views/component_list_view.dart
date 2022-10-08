import 'package:flutter/material.dart';
import 'package:prodeye/models/production.dart';
import 'package:prodeye/widgets/component_row.dart';
import 'package:provider/provider.dart';

import 'dart:developer';

import 'package:prodeye/models/profile.dart';
import 'package:prodeye/widgets/error_widget.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/models/settings.dart';

class ComponentListView extends StatelessWidget {
  static String routeName = "ComponentListView";
  const ComponentListView({super.key});
  @override
  Widget build(BuildContext context) {
    var myProduction = ModalRoute.of(context)!.settings.arguments;
    ProdEyeSettings settingObj =
        Provider.of<ProdiSettings>(context).settingObject;

    ProdiLog.debug(settingObj.logLevel, "${this.runtimeType.toString()} build",
        "starting build of ${this.runtimeType.toString()}");
    Size screenSize = MediaQuery.of(context).size;

    try {
      if (myProduction is! Production) {
        throw Exception(["no Production object available"]);
      }
      var retVal = Scaffold(
        appBar: AppBar(
          title: GestureDetector(child: Text(myProduction.name), onTap: () {}),
        ),
        body: SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: ListView.builder(
            itemBuilder: (ctx, idx) {
              return ComponentRow(
                  component: myProduction.components.components[idx]);
            },
            itemCount: myProduction.components.components.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
          ),
        ),
      );
      ProdiLog.debug(
          settingObj.logLevel,
          "${this.runtimeType.toString()} build",
          "ending build of ${this.runtimeType.toString()}");
      return retVal;
    } catch (eError, sTackTrace) {
      ProdiLog.error(settingObj.logLevel, "ComponentListView",
          "error in ComponentListView ${eError.toString()}",
          stackTrace: sTackTrace.toString());
      Navigator.of(context).pop();

      return ProdiErrorWidget(
          MessageOfError: "Error During Displaying Component List widget");
    }
  }
}
