import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:prodeye/common_utils/query_key.dart';
import 'package:provider/provider.dart';

import 'package:prodeye/models/component.dart';
import 'package:prodeye/models/component_log.dart';
import 'package:prodeye/widgets/base_renderer.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';

class ComponentLogDisplay extends StatefulWidget {
  Component myComponent;
  ComponentLogDisplay({required this.myComponent, super.key});
  @override
  State<ComponentLogDisplay> createState() => _ComponentLogDisplay();
}

class _ComponentLogDisplay extends State<ComponentLogDisplay>
    with BaseStateRenderer {
  Color getShadowColor(ComponentLog cmpLog) {
    if (cmpLog.type == 'Error') {
      return Colors.red;
    } else if (cmpLog.type == 'Warning') {
      return Colors.orange;
    } else if (cmpLog.type == 'Alert') {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget realBuild(BuildContext context) {
    List<ComponentLog> compLogsList = [
      ...widget.myComponent.errors.componentLogs,
      ...widget.myComponent.warnings.componentLogs,
      ...widget.myComponent.alerts.componentLogs
    ];
    compLogsList.sort((a, b) => b.id.compareTo(a.id));
    Size screenSize = MediaQuery.of(context).size;

    return ListView.builder(
      itemBuilder: (context, indx) {
        ComponentLog logItm = compLogsList[indx];

        return SizedBox(
          height: screenSize.height * 0.2,
          width: screenSize.width * 0.9,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            shadowColor: getShadowColor(logItm),
            elevation: 2.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        style: TextStyle(
                          color: getShadowColor(logItm),
                        ),
                        logItm.type,
                      ),
                    ),
                  ],
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(DateTime.parse(logItm.logTime)
                          .toLocal()
                          .toString()
                          .split(".")[0]),
                    )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        logItm.logMessage,
                        softWrap: true,
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      itemCount: compLogsList.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
    );
  }

  @override
  Widget build(BuildContext context) {
    settingObject = Provider.of<ProdiSettings>(context).settingObject;

    return super.build(context);
  }
}
