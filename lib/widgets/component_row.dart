import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:prodeye/models/component.dart';
import 'package:prodeye/widgets/base_renderer.dart';
import 'package:prodeye/widgets/common.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/views/component_detail_view.dart';

class ComponentRow extends StatefulWidget {
  Component component;
  ComponentRow({required this.component, super.key});
  @override
  State<ComponentRow> createState() => _ComponentRow();
}

class _ComponentRow extends State<ComponentRow> with BaseStateRenderer {
  Color getShadowColor(Component cmp) {
    if (cmp.errors.componentLogs.isNotEmpty) {
      return Colors.red;
    } else if (cmp.warnings.componentLogs.isNotEmpty) {
      return Colors.orange;
    } else if (cmp.alerts.componentLogs.isNotEmpty) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget realBuild(BuildContext context) {
    Component comp = widget.component;
    List<int> compMessageAvg = comp.queMessages.componentQueueMessageStats
        .map((e) => e.messageAVGProcessingMilliseconds)
        .toList();
    double avgProcessing = compMessageAvg.isNotEmpty
        ? (compMessageAvg
                .reduce((value, element) => value + element)
                .toDouble()) /
            comp.queMessages.componentQueueMessageStats.length.toDouble()
        : 0.0;
    List<Widget> dataWidgetList = [];
    dataWidgetList.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        comp.name,
        style: const TextStyle(fontSize: 20),
      ),
    ));
    List<int> compMessageCount =
        comp.queMessages.componentQueueMessageStats.length > 1
            ? comp.queMessages.componentQueueMessageStats
                .map((e) => e.messageCount)
                .toList()
            : [];
    dataWidgetList.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
            "${compMessageCount.isNotEmpty ? compMessageCount.reduce((value, element) => value + element).toString() : 0} Messages Processed"),
      ),
    );
    if (comp.type != "null") {
      dataWidgetList.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(comp.type),
      ));
    }
    if (avgProcessing > 0) {
      dataWidgetList.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Average time per message ${avgProcessing.toString()}"),
      ));
    }
    if (comp.errors.componentLogs.isNotEmpty) {
      dataWidgetList.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("${comp.errors.componentLogs.length} errors"),
      ));
    }
    if (comp.warnings.componentLogs.isNotEmpty) {
      dataWidgetList.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("${comp.warnings.componentLogs.length}  warnings"),
      ));
    }
    if (comp.alerts.componentLogs.isNotEmpty) {
      dataWidgetList.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("${comp.alerts.componentLogs.length}  alerts"),
      ));
    }
    Widget retBuild = GestureDetector(
        onTap: () {
          componentDetailRouteArguments params =
              componentDetailRouteArguments(comp: comp, displayChart: false);
          Navigator.of(context)
              .pushNamed(ComponentDetailView.routeName, arguments: params);
        },
        child: ClipRRect(
            child: Card(
                shadowColor: getShadowColor(comp),
                elevation: 2.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(children: dataWidgetList))));
    return retBuild;
  }

  @override
  Widget build(BuildContext context) {
    settingObject = Provider.of<ProdiSettings>(context).settingObject;

    return super.build(context);
  }
}
