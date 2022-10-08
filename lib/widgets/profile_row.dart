import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:prodeye/models/profile.dart';
import 'package:prodeye/providers/profile_provider.dart';
import 'package:prodeye/providers/profile_entry.dart';
import 'package:prodeye/views/profile_detail_view.dart';
import 'package:prodeye/common_utils/query_key.dart';
import 'package:prodeye/views/production_list_view.dart';
import 'package:prodeye/models/settings.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/widgets/base_renderer.dart';
import 'package:prodeye/widgets/common.dart';

class ProfileRow extends StatefulWidget {
  final DateTime datefrom;
  final DateTime dateto;
  ProfileRow({required this.datefrom, required this.dateto});

  @override
  State<ProfileRow> createState() => _ProfileRowState();
}

class _ProfileRowState extends State<ProfileRow> with BaseStateRenderer {
  bool loadingIndicator = false;

  void displayLoadingRow(bool value) {
    setState(() {
      loadingIndicator = value;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<bool> showAlertDialog(BuildContext context) async {
    AlertDialog confirmBox = AlertDialog(
      title: const Text("Delete"),
      content: const Text("Are you Sure?"),
      actions: [
        ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            label: const Text("delete"),
            icon: const Icon(Icons.delete_forever)),
        ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            label: const Text("cancel"),
            icon: const Icon(Icons.cancel))
      ],
    );
    bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return confirmBox;
      },
    );
    return result is bool ? result : false;
  }

  @override
  Widget realBuild(BuildContext context) {
    ProfileProvider profileListProvider = Provider.of<ProfileProvider>(context);
    ProfileEntryProvider profileProvider =
        Provider.of<ProfileEntryProvider>(context);

    return GestureDetector(
      onTap: !loadingIndicator
          ? () async {
              displayLoadingRow(true);
              profileProvider
                  .loadDataByDateTimeFrame(widget.datefrom, widget.dateto)
                  .then((value) {
                displayLoadingRow(false);
                Navigator.of(context).pushNamed(ProductionListView.routeName,
                    arguments: profileProvider.currentProfile);
              });
            }
          : null,
      child: ClipRRect(
        child: Card(
          elevation: 2.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.cyan,
          child: Column(
            children: [
              Row(
                children: [Text(profileProvider.currentProfile.name)],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: loadingIndicator,
                    child: const CircularProgressIndicator(
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  Text(profileProvider.currentProfile.lastQueriedKey.isNotEmpty
                      ? "last update ${formatDate(QueryKey.getDateTimeFromQueryKey(profileProvider.currentProfile.lastQueriedKey).toLocal())}"
                      : "last update date not available"),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                            ProfileDetailView.routeName,
                            arguments: profileProvider.currentProfile);
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () {
                        showAlertDialog(context).then((value) {
                          if (value) {
                            Profile.KVStoreHook.deleteEntryById(
                                    profileProvider.currentProfile.runtimeType
                                        .toString(),
                                    profileProvider.currentProfile.id)
                                .then((value) =>
                                    profileListProvider.buildProfileList());
                          }
                        });
                      },
                      icon: const Icon(Icons.delete)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    settingObject = Provider.of<ProdiSettings>(context).settingObject;

    return super.build(context);
  }
}
