import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'dart:developer';
import 'dart:io';

import 'package:prodeye/views/profile_view.dart';
import 'package:prodeye/logger/logger.dart';
import 'package:prodeye/widgets/error_widget_embeddable.dart';
import 'package:provider/provider.dart';

class ProdiErrorWidget extends StatelessWidget {
  String MessageOfError;
  ProdiErrorWidget({required this.MessageOfError});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(child: const Text("Prodi"), onTap: () {}),
      ),
      body: SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: ProdiErrorEmbeddedWidget(MessageOfError: this.MessageOfError)),
    );
  }
}
