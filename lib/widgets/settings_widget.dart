import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/widgets/base_renderer.dart';

class SettingsEditWidget extends StatefulWidget {
  const SettingsEditWidget({super.key});

  @override
  State<SettingsEditWidget> createState() => _SettingsEditWidgetState();
}

class _SettingsEditWidgetState extends State<SettingsEditWidget>
    with BaseStateRenderer {
  static final _formKey = GlobalKey<FormState>();
  int cachePortNum = 0;

  int screenRefreshNum = 0;

  int dataTaskNum = 0;

  int cacheTaskNum = 0;

  final FocusNode screenRefreshFocus = FocusNode();

  final FocusNode dataTaskFocus = FocusNode();

  final FocusNode cacheTaskFocus = FocusNode();

  final FocusNode submitFocus = FocusNode();

  @override
  Widget realBuild(BuildContext context) {
    cachePortNum = cachePortNum == 0
        ? settingObject.internalCacheServicePort
        : cachePortNum;
    screenRefreshNum = screenRefreshNum == 0
        ? settingObject.screenDataRefreshIntervalSeconds
        : screenRefreshNum;
    dataTaskNum =
        dataTaskNum == 0 ? settingObject.dataTaskIntervalMinutes : dataTaskNum;
    cacheTaskNum = cacheTaskNum == 0
        ? settingObject.cacheTaskIntervalMinutes
        : cacheTaskNum;
    TextEditingController cachePort =
        TextEditingController(text: cachePortNum.toString());
    TextEditingController screenRefresh =
        TextEditingController(text: screenRefreshNum.toString());
    TextEditingController dataTask =
        TextEditingController(text: dataTaskNum.toString());
    TextEditingController cacheTask =
        TextEditingController(text: cacheTaskNum.toString());

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: cachePort,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Internal Cache Service Port",
                  icon: Icon(Icons.podcasts)),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) is! int) {
                  return 'Please enter valid number';
                }
                return null;
              },
              onChanged: (value) => cachePortNum =
                  int.tryParse(value) is int ? int.parse(value) : cachePortNum,
              onFieldSubmitted: (value) =>
                  FocusScope.of(context).requestFocus(screenRefreshFocus),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: screenRefresh,
              focusNode: screenRefreshFocus,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Screen Data Refresh Interval Seconds",
                  icon: Icon(Icons.podcasts)),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) is! int) {
                  return 'Please enter valid number';
                }
                return null;
              },
              onChanged: (value) => screenRefreshNum =
                  int.tryParse(value) is int
                      ? int.parse(value)
                      : screenRefreshNum,
              onFieldSubmitted: (value) =>
                  FocusScope.of(context).requestFocus(dataTaskFocus),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: dataTask,
              focusNode: dataTaskFocus,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Background Process for Data Interval Minutes",
                  icon: Icon(Icons.podcasts)),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) is! int) {
                  return 'Please enter valid number';
                }
                return null;
              },
              onChanged: (value) => dataTaskNum =
                  int.tryParse(value) is int ? int.parse(value) : dataTaskNum,
              onFieldSubmitted: (value) =>
                  FocusScope.of(context).requestFocus(cacheTaskFocus),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: cacheTask,
              focusNode: cacheTaskFocus,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Background Process for Cache Interval Minutes",
                  icon: Icon(Icons.podcasts)),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) is! int) {
                  return 'Please enter valid number';
                }
                return null;
              },
              onChanged: (value) => cacheTaskNum =
                  int.tryParse(value) is int ? int.parse(value) : cacheTaskNum,
              onFieldSubmitted: (value) =>
                  FocusScope.of(context).requestFocus(submitFocus),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  focusNode: submitFocus,
                  onPressed: (() async {
                    if (_formKey.currentState!.validate()) {
                      settingObject.internalCacheServicePort = cachePortNum;
                      settingObject.screenDataRefreshIntervalSeconds =
                          screenRefreshNum;
                      settingObject.dataTaskIntervalMinutes = dataTaskNum;
                      settingObject.cacheTaskIntervalMinutes = cacheTaskNum;
                      await ProdEyeSettings.KVStoreHook.writeRecord(
                          settingObject);
                    }
                    Navigator.of(context).pop();
                  }))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    settingObject = Provider.of<ProdiSettings>(context).settingObject;

    return super.build(context);
  }
}
