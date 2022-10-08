import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:prodeye/models/production.dart';

import 'package:provider/provider.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/widgets/base_renderer.dart';

class ProductionSettings extends StatefulWidget {
  Production prod;
  ProductionSettings({super.key, required this.prod});
  @override
  State<ProductionSettings> createState() => _ProductionSettings();
}

class _ProductionSettings extends State<ProductionSettings>
    with BaseStateRenderer {
  static final _formKey = GlobalKey<FormState>();

  bool errorShow = true;
  bool warnShow = true;
  bool alertShow = true;
  bool jobShow = true;
  bool queueShow = true;

  @override
  Widget realBuild(BuildContext context) {
    errorShow = widget.prod.showErrorNotification;
    warnShow = widget.prod.showWarningrNotification;
    alertShow = widget.prod.showAlertNotification;
    jobShow = widget.prod.showJobNotification;
    queueShow = widget.prod.showQueueNotification;
    Scaffold retBuild = Scaffold(
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
                      "Enable Notifications for Errors",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: errorShow,
                        onChanged: (value) async {
                          widget.prod.showErrorNotification = value;
                          widget.prod.update("ID", "=");
                          setState(() {
                            errorShow = value;
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
                      "Enable Notifications for Warnings",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: warnShow,
                        onChanged: (value) async {
                          widget.prod.showWarningrNotification = value;
                          widget.prod.update("ID", "=");
                          setState(() {
                            warnShow = value;
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
                      "Enable Notifications for Alerts",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: alertShow,
                        onChanged: (value) async {
                          widget.prod.showAlertNotification = value;
                          widget.prod.update("ID", "=");
                          setState(() {
                            alertShow = value;
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
                      "Enable Notifications for Jobs",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: jobShow,
                        onChanged: (value) async {
                          widget.prod.showJobNotification = value;
                          widget.prod.update("ID", "=");
                          setState(() {
                            jobShow = value;
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
                      "Enable Notifications for Queue Size",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    CupertinoSwitch(
                        value: queueShow,
                        onChanged: (value) async {
                          widget.prod.showQueueNotification = value;
                          widget.prod.update("ID", "=");
                          setState(() {
                            queueShow = value;
                          });
                        }),
                  ],
                ),
              ),
            ]))));
    return retBuild;
  }

  @override
  Widget build(BuildContext context) {
    settingObject = Provider.of<ProdiSettings>(context).settingObject;

    return super.build(context);
  }
}
