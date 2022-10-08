import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import 'package:prodeye/models/component.dart';
import 'package:prodeye/models/component_queue_and_messages.dart';
import 'package:prodeye/widgets/base_renderer.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';

class ComponentStatsDisplay extends StatefulWidget {
  Component myComponent;
  ComponentStatsDisplay({required this.myComponent, super.key});
  @override
  State<ComponentStatsDisplay> createState() => _ComponentStatsDisplay();
}

class _ComponentStatsDisplay extends State<ComponentStatsDisplay>
    with BaseStateRenderer {
  @override
  Widget realBuild(BuildContext context) {
    List<FlSpot> componentMsgs = widget
        .myComponent.queMessages.componentQueueMessageStats
        .map((e) => FlSpot(double.parse(e.qKey.toString()),
            double.parse(e.messageCount.toString())))
        .toList();
    List<FlSpot> componentAvgs = widget
        .myComponent.queMessages.componentQueueMessageStats
        .map((e) => FlSpot(double.parse(e.qKey.toString()),
            double.parse(e.messageAVGProcessingMilliseconds.toString())))
        .toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: componentMsgs,
            dotData: FlDotData(show: false),
            color: Colors.blueGrey,
          ),
          LineChartBarData(
            spots: componentAvgs,
            dotData: FlDotData(show: false),
            color: Colors.cyan,
          ),
        ],
        // control how the chart looks
      ),
      swapAnimationDuration: const Duration(milliseconds: 60), // Optional
      swapAnimationCurve: Curves.linear, // Optional
    );
  }

  @override
  Widget build(BuildContext context) {
    settingObject = Provider.of<ProdiSettings>(context).settingObject;

    return super.build(context);
  }
}
