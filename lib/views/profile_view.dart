import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:prodeye/providers/profile_provider.dart';
import 'package:prodeye/views/profile_detail_view.dart';
import 'package:prodeye/widgets/profile_row.dart';
import 'package:prodeye/widgets/drawer.dart';
import 'package:prodeye/widgets/error_widget.dart';
import 'package:prodeye/logger/logger_utils.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/views/notification_list.dart';
import 'package:prodeye/widgets/common.dart';
import 'package:prodeye/providers/notification_provider.dart';
import 'package:prodeye/models/notification.dart';

class ProfileListView extends StatefulWidget {
  static String routeName = "ProfileListView";
  final _formKey = GlobalKey<FormState>();

  DateTime datefrom = DateTime.now().subtract(const Duration(hours: 1)).toUtc();
  DateTime dateto = DateTime.now().toUtc();
  bool isCustomDate = false;

  ProfileListView({super.key});
  @override
  State<ProfileListView> createState() => _ProfileListViewState();
}

class _ProfileListViewState extends State<ProfileListView> {
  refreshDateRange(DateTime datef, DateTime datet) {
    setState(() {
      widget.datefrom = datef;
      widget.dateto = datet;
      widget.isCustomDate = !widget.isCustomDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    ProfileProvider myProfiles = Provider.of<ProfileProvider>(context);

    ProdEyeSettings settingObj =
        Provider.of<ProdiSettings>(context).settingObject;

    PordiNotificationProvider myNoteProvider =
        Provider.of<PordiNotificationProvider>(context);
    List<ProdiNotification> notifs = myNoteProvider.listOfNotifs;

    ProdiLog.debug(settingObj.logLevel, "${this.runtimeType.toString()} build",
        "starting build of ${this.runtimeType.toString()}");

    Size screenSize = MediaQuery.of(context).size;

    try {
      //for (ProfileEntryProvider prov in myProfiles.listOfProfileProviders) {
      // prov.loadDataByDateTimeFrame(widget.datefrom, widget.dateto);
      //}

      var retVal = Scaffold(
        appBar: AppBar(
          title: GestureDetector(child: const Text("Prodi"), onTap: () {}),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(ProfileDetailView.routeName);
                },
                icon: const Icon(Icons.add)),
            Stack(
              children: [
                Text(
                  notifs.where((nota) => !nota.shown).length.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(NotificationListView.routeName);
                    },
                    icon: const Icon(Icons.notifications))
              ],
            ),
          ],
        ),
        body: SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: ListView.builder(
            itemBuilder: (ctx, idx) {
              if ((idx == 0) && (widget.isCustomDate)) {
                return Column(
                  children: [
                    Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: screenSize.width * 0.7,
                                child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: 2.5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '''${formatDate(widget.datefrom)} to ${formatDate(widget.dateto)}''',
                                      maxLines: 20,
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                  tooltip: "Reset",
                                  onPressed: () {
                                    refreshDateRange(
                                        DateTime.now()
                                            .subtract(const Duration(hours: 1))
                                            .toUtc(),
                                        DateTime.now().toUtc());
                                  },
                                  icon: const Icon(
                                    Icons.restore_page,
                                    semanticLabel: "Reset",
                                  ))
                            ])
                      ],
                    ),
                    ChangeNotifierProvider.value(
                      value: myProfiles.listOfProfileProviders[idx],
                      child: ProfileRow(
                          datefrom: widget.datefrom, dateto: widget.dateto),
                    )
                  ],
                );
              } else {
                return ChangeNotifierProvider.value(
                  value: myProfiles.listOfProfileProviders[idx],
                  child: ProfileRow(
                      datefrom: widget.datefrom, dateto: widget.dateto),
                );
              }
            },
            itemCount: myProfiles.listOfProfileProviders.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
          ),
        ),
        drawer: ProdiDrawer(),
        floatingActionButton: FloatingActionButton(
          backgroundColor:
              widget.isCustomDate ? Colors.lightBlueAccent : Colors.transparent,
          splashColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.calendar_today_rounded,
            color: Color(0xFF272F7A),
          ),
          onPressed: () async {
            await showDatePicker(
                    helpText: "starting Date for your query of profiles data",
                    context: context,
                    initialDate: widget.datefrom.toLocal(),
                    firstDate: DateTime(2000, 1, 1),
                    lastDate: DateTime.now())
                .then((dtfvalue) async {
              if (dtfvalue != null) {
                await showTimePicker(
                        helpText:
                            "starting Time for your query of profiles data",
                        context: context,
                        initialTime: TimeOfDay(
                            hour: widget.datefrom.toLocal().hour,
                            minute: widget.datefrom.toLocal().second))
                    .then((tmfvalue) async {
                  if (tmfvalue != null) {
                    DateTime newDateFrom = DateTime(
                        dtfvalue.year,
                        dtfvalue.month,
                        dtfvalue.day,
                        tmfvalue.hour,
                        tmfvalue.minute);
                    widget.datefrom = newDateFrom;

                    await showDatePicker(
                            helpText:
                                "ending Date for your query of profiles data",
                            context: context,
                            initialDate: widget.dateto.toLocal(),
                            firstDate: DateTime(2000, 1, 1),
                            lastDate: DateTime.now())
                        .then((dttvalue) async {
                      if (dttvalue != null) {
                        showTimePicker(
                                helpText:
                                    "ending Time for your query of profiles data",
                                context: context,
                                initialTime: TimeOfDay(
                                    hour: widget.dateto.toLocal().hour,
                                    minute: widget.dateto.toLocal().second))
                            .then((tmtvalue) {
                          if (tmtvalue is TimeOfDay) {
                            DateTime newDateTo = DateTime(
                                dttvalue.year,
                                dttvalue.month,
                                dttvalue.day,
                                tmtvalue.hour,
                                tmtvalue.minute);
                            refreshDateRange(widget.datefrom, newDateTo);
                          }
                        });
                      }
                    });
                  }
                });
              }
            });
          },
        ),
      );

      return retVal;
    } catch (eError, sTackTrace) {
      ProdiLog.error(
          settingObj.logLevel, "ProfileListView", "error in ProfileListView",
          stackTrace: sTackTrace.toString());

      return ProdiErrorWidget(
          MessageOfError: "Error During Displaying Profiles List widget");
    }
  }
}
