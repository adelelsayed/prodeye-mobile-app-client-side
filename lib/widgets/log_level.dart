import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:prodeye/logger/logger_levels.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:prodeye/widgets/base_renderer.dart';

class LogLevel extends StatefulWidget {
  static String routeName = "LogLevel";
  @override
  State<LogLevel> createState() => _LogLevel();
}

class _LogLevel extends State<LogLevel> with BaseStateRenderer {
  String textMessage = "";

  void rebuild(String newMessage) {
    setState(() {
      textMessage = newMessage;
    });
  }

  @override
  Widget realBuild(BuildContext context) {
    ProdEyeSettings settingObj =
        Provider.of<ProdiSettings>(context).settingObject;
    textMessage = settingObj.logLevel.name;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RangeSlider(
          values: RangeValues(0, settingObj.logLevel.index.toDouble()),
          divisions: ProdiLogLevels.values.length,
          min: 0,
          max: 4,
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
          onChanged: (RangeValues newValues) async {
            ProdiLogLevels newLevel =
                ProdiLogLevels.values[newValues.end.toInt()];
            settingObj.logLevel = newLevel;
            await ProdEyeSettings.KVStoreHook.writeRecord(settingObj);
            rebuild(newLevel.name.toString());
          },
          labels: const RangeLabels("", "Log Level"),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            textMessage,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    settingObject = Provider.of<ProdiSettings>(context).settingObject;

    return super.build(context);
  }
}
