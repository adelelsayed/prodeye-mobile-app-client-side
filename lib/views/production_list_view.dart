import 'package:flutter/material.dart';
import 'package:prodeye/widgets/production_row.dart';
import 'package:provider/provider.dart';

import 'dart:developer';

import 'package:prodeye/models/profile.dart';
import 'package:prodeye/widgets/error_widget.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/models/settings.dart';

class ProductionListView extends StatelessWidget {
  static String routeName = "ProductionListView";
  const ProductionListView({super.key});
  @override
  Widget build(BuildContext context) {
    var myProfile = ModalRoute.of(context)!.settings.arguments;
    ProdEyeSettings settingObj =
        Provider.of<ProdiSettings>(context).settingObject;

    ProdiLog.debug(settingObj.logLevel, "${this.runtimeType.toString()} build",
        "starting build of ${this.runtimeType.toString()}");
    Size screenSize = MediaQuery.of(context).size;

    try {
      if (myProfile is! Profile) {
        throw Exception(["no Profile object available"]);
      }
      var retVal = Scaffold(
        appBar: AppBar(
          title: GestureDetector(child: Text(myProfile.name), onTap: () {}),
        ),
        body: SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: ListView.builder(
            itemBuilder: (ctx, idx) {
              return ProductionRow(
                  production: myProfile.productionObjects.productions[idx]);
            },
            itemCount: myProfile.productionObjects.productions.length,
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
      ProdiLog.error(settingObj.logLevel, "ProductionListView",
          "error in ProductionListView ${eError.toString()}",
          stackTrace: sTackTrace.toString());
      Navigator.of(context).pop();

      return ProdiErrorWidget(
          MessageOfError: "Error During Displaying Production List widget");
    }
  }
}
