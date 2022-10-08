import 'dart:async';
import 'package:prodeye/views/component_list_view.dart';
import 'package:prodeye/views/production_settings.dart';
import 'package:prodeye/widgets/common.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:prodeye/models/component.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/models/production.dart';
import 'package:prodeye/widgets/base_renderer.dart';

class ProductionRow extends StatefulWidget {
  Production production;
  ProductionRow({required this.production, super.key});
  @override
  State<ProductionRow> createState() => _ProductionRowState();
}

class _ProductionRowState extends State<ProductionRow> with BaseStateRenderer {
  _ProductionRowState();

  @override
  Widget realBuild(BuildContext context) {
    Production productn = widget.production;
    List<Widget> dataWidgetList = [];

    Size screenSize = MediaQuery.of(context).size;

    dataWidgetList.add(Text(
      productn.name,
      style: const TextStyle(fontSize: 20),
    ));

    if (productn.status.isNotEmpty) {
      dataWidgetList.add(Text(productn.status));
    }

    if (productn.status.isNotEmpty) {
      if (productn.status != "Running") {
        dataWidgetList.add(Text(
            "${productn.status} As of ${productn.statusAsOf.toLocal().toString().split(".")[0]}",
            style: redStyle));
      }
    }
    List<Component> compWithError = productn.components.components
        .where((element) => element.errors.componentLogs.isNotEmpty)
        .toList();
    if (compWithError.isNotEmpty) {
      dataWidgetList.add(Text("${compWithError.length} components has errors",
          style: redStyle));
    }
    List<Component> compWithWarn = productn.components.components
        .where((element) => element.warnings.componentLogs.isNotEmpty)
        .toList();
    if (compWithWarn.isNotEmpty) {
      dataWidgetList.add(Text("${compWithWarn.length} components has warnings",
          style: orangeStyle));
    }

    List<Component> compWithAlert = productn.components.components
        .where((element) => element.alerts.componentLogs.isNotEmpty)
        .toList();
    if (compWithAlert.isNotEmpty) {
      dataWidgetList.add(Text("${compWithAlert.length} components has alerts",
          style: blueStyle));
    }

    List<Component> compWithBadJob = productn.components.components
        .where((element) => element.jobs.componentJobs
            .where((job) =>
                !["running", "dequeuing", "Listening"].contains(job.status))
            .isNotEmpty)
        .toList();
    if (compWithAlert.isNotEmpty) {
      dataWidgetList.add(Text(
          "${compWithBadJob.length} components has troubled jobs",
          style: redStyle));
    }

    Widget retVal = GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ComponentListView.routeName, arguments: productn);
        },
        child: ClipRRect(
            child: Card(
                shadowColor: !(["Running"].contains(productn.status))
                    ? Colors.red
                    : Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                        width: screenSize.width * 0.8,
                        child: Column(children: dataWidgetList)),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                              ProductionSettingsView.routeName,
                              arguments: productn);
                        },
                        icon: const Icon(Icons.settings))
                  ],
                ))));
    return retVal;
  }

  @override
  Widget build(BuildContext context) {
    settingObject = Provider.of<ProdiSettings>(context).settingObject;

    return super.build(context);
  }
}
