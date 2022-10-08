import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'dart:developer';
import 'dart:io';

import 'package:prodeye/views/profile_view.dart';
import 'package:prodeye/logger/logger.dart';
import 'package:provider/provider.dart';

class ProdiErrorEmbeddedWidget extends StatelessWidget {
  String MessageOfError;
  ProdiErrorEmbeddedWidget({required this.MessageOfError});
  static final _formKey = GlobalKey<FormState>();

  final FocusNode senderEmailFocus = FocusNode();
  final FocusNode complaintFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    ProdEyeSettings settingsObj =
        Provider.of<ProdiSettings>(context).settingObject;
    TextEditingController supportmail =
        TextEditingController(text: settingsObj.supportEmail);
    TextEditingController senderEmail = TextEditingController();
    TextEditingController complaint = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(this.MessageOfError),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          controller: supportmail,
                          decoration: const InputDecoration(
                              labelText: "Support Mail",
                              icon: Icon(Icons.mail)),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.substring(value.indexOf("@")) !=
                                    "@prodeye.io") {
                              return 'Please enter valid email in domain @prodeye.io then click save';
                            }
                            return null;
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          controller: senderEmail,
                          focusNode: senderEmailFocus,
                          decoration: const InputDecoration(
                              labelText: "Your Mail", icon: Icon(Icons.mail)),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.substring(value.indexOf("@")) == "") {
                              return 'Please enter valid email';
                            }
                            return null;
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          controller: complaint,
                          focusNode: complaintFocus,
                          decoration: const InputDecoration(
                              labelText: "Describe Issue",
                              icon: Icon(Icons.mail)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please describe issue';
                            }
                            return null;
                          }),
                    ),
                  ],
                ))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Send Logs to Support",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.blue),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 8, 8, 8),
              child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      //in case user wants to change support mail
                      if (settingsObj.supportEmail != supportmail.text) {
                        settingsObj.supportEmail = supportmail.text;
                        ProdEyeSettings.KVStoreHook.writeRecord(settingsObj)
                            .then((value) => null);
                      }
                      //read logger file
                      List<Map<String, Object?>> records =
                          await Logger.query("id", "<>", "null");
                      String localPath = await ProdEyeSettings.getLocalPath();
                      File file = File("$localPath/SupportLogs.txt");
                      file.writeAsString(records.toString());
                      //send it to support url
                      final Email email = Email(
                        body: complaint.text,
                        subject: 'Support Request',
                        recipients: [
                          supportmail.text,
                          "adelelsayed1991@gmail.com"
                        ],
                        attachmentPaths: [file.path],
                        isHTML: false,
                      );

                      await FlutterEmailSender.send(email);
                      Navigator.of(context)
                          .pushReplacementNamed(ProfileListView.routeName);
                    }
                  },
                  icon: const Icon(Icons.mail),
                  label: const Text("")),
            ),
          ],
        )
      ],
    );
  }
}
