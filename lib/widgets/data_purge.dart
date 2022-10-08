import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:prodeye/logger/logger.dart';
import 'package:prodeye/models/component_log.dart';
import 'package:prodeye/models/component_queue_and_messages.dart';
import 'package:prodeye/models/notification.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/widgets/base_renderer.dart';
import 'package:prodeye/common_utils/query_key.dart';

class DataPurge extends StatefulWidget {
  @override
  State<DataPurge> createState() => _DataPurgeState();
}

class _DataPurgeState extends State<DataPurge> with BaseStateRenderer {
  static final _formKey = GlobalKey<FormState>();

  DateTime cutoff = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 30);

  bool purgeProdiLogs = false;

  bool purgeProdiNotifications = false;

  bool purgeErrors = false;

  bool purgeWarnings = false;

  bool purgeAlerts = false;

  bool purgeJobs = false;

  bool purgeMessageCounts = false;

  bool isPurging = false;

  @override
  Widget realBuild(BuildContext context) {
    Widget retBuild = Scaffold(
        appBar: AppBar(title: const Text("Prodi")),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Purge ProdEye Application Logs",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: purgeProdiLogs,
                        onChanged: (value) {
                          setState(() {
                            purgeProdiLogs = value;
                          });
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Purge Notifications",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: purgeProdiNotifications,
                        onChanged: (value) {
                          setState(() {
                            purgeProdiNotifications = value;
                          });
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Purge Errors",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: purgeErrors,
                        onChanged: (value) {
                          setState(() {
                            purgeErrors = value;
                          });
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Purge Warnings",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: purgeWarnings,
                        onChanged: (value) {
                          setState(() {
                            purgeWarnings = value;
                          });
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Purge Alerts",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: purgeAlerts,
                        onChanged: (value) {
                          setState(() {
                            purgeAlerts = value;
                          });
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Purge Job Data",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: purgeJobs,
                        onChanged: (value) {
                          setState(() {
                            purgeJobs = value;
                          });
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Purge Message Count Data",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: purgeMessageCounts,
                        onChanged: (value) {
                          setState(() {
                            purgeMessageCounts = value;
                          });
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("Purge Before: "),
                      SizedBox(
                        height: 75,
                        width: 200,
                        child: InputDatePickerFormField(
                          keyboardType: TextInputType.datetime,
                          firstDate: DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day - 1095),
                          lastDate: DateTime.now(),
                          initialDate: DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day - 30),
                          onDateSubmitted: (date) {
                            setState(() {
                              cutoff = date.toUtc();
                            });
                          },
                        ),
                      )
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Visibility(
                  visible: isPurging,
                  child: const CircularProgressIndicator(
                    color: Colors.lightBlueAccent,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isPurging = true;
                        });
                        int pQkey =
                            int.parse(QueryKey.getQueryKeyFromDateTime(cutoff));
                        if (purgeErrors) {
                          await ComponentLog.purge(pQkey, "Error");
                        }
                        log("1");
                        if (purgeWarnings) {
                          await ComponentLog.purge(pQkey, "Warning");
                        }
                        log("2");
                        if (purgeAlerts) {
                          await ComponentLog.purge(pQkey, "Alert");
                        }
                        log("3");
                        if (purgeMessageCounts) {
                          await ComponentQueueMessageStats.purge(pQkey);
                        }
                        log("4");
                        if (purgeProdiNotifications) {
                          await ProdiNotification.purge(pQkey);
                        }
                        log("5");
                        if (purgeProdiLogs) {
                          await Logger.purge(pQkey);
                        }
                        log("6");
                        setState(() {
                          isPurging = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Submit")),
              )
            ]))));
    return retBuild;
  }

  @override
  Widget build(BuildContext context) {
    settingObject = Provider.of<ProdiSettings>(context).settingObject;

    return super.build(context);
  }
}
