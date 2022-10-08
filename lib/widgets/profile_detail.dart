import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:prodeye/models/profile.dart';
import 'package:prodeye/providers/profile_provider.dart';
import 'package:prodeye/models/utils.dart';
import 'package:prodeye/providers/settings_provider.dart';
import 'package:prodeye/widgets/base_renderer.dart';

class ProfileDetail extends StatefulWidget {
  ProfileDetail({super.key});

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> with BaseStateRenderer {
  static final _formKey = GlobalKey<FormState>();

  bool isEnabled = false;
  String nameField = "";
  String urlField = "";
  String usernameField = "";
  String passwordField = "";
  int intervalMinsField = 0;
  int cacheDaysField = 30;
  String authModeField = "";
  bool showAuthUrlfield = false;
  String authUrlField = "";
  bool isRebuild = false;

  final FocusNode profileNameFocus = FocusNode();
  final FocusNode profileURLFocus = FocusNode();
  final FocusNode profileUserNameFocus = FocusNode();
  final FocusNode profilePassWordFocus = FocusNode();
  final FocusNode profileSyncMinutesFocus = FocusNode();
  final FocusNode profileCacheDaysFocus = FocusNode();
  final FocusNode profileAuthModeFocus = FocusNode();

  @override
  Widget realBuild(BuildContext context) {
    var profileEntry = ModalRoute.of(context)!.settings.arguments;
    ProfileProvider ProfileProviderObj =
        Provider.of<ProfileProvider>(context, listen: false);

    TextEditingController pName = profileEntry is Profile
        ? TextEditingController(text: profileEntry.name)
        : TextEditingController(text: nameField);
    TextEditingController pURL = profileEntry is Profile
        ? TextEditingController(text: profileEntry.url)
        : TextEditingController(text: urlField);
    TextEditingController pUserName = profileEntry is Profile
        ? TextEditingController(text: profileEntry.username)
        : TextEditingController(text: usernameField);
    TextEditingController pPassWord = profileEntry is Profile
        ? TextEditingController(text: profileEntry.password)
        : TextEditingController(text: passwordField);
    TextEditingController intervalMinutesController = profileEntry is Profile
        ? TextEditingController(
            text: profileEntry.dataBackgroundSyncIntervalMinutes.toString())
        : TextEditingController(text: intervalMinsField.toString());

    TextEditingController pcacheDays = profileEntry is Profile
        ? TextEditingController(text: profileEntry.cacheDays.toString())
        : TextEditingController(text: cacheDaysField.toString());

    TextEditingController pAuthURL = profileEntry is Profile
        ? TextEditingController(text: profileEntry.authUrl)
        : TextEditingController();

    isEnabled = profileEntry is Profile && profileEntry.dataBackgroundSync == 1
        ? true
        : false;
    if (!isRebuild) {
      showAuthUrlfield = (profileEntry is Profile &&
              profileEntry.authMode == ProdiAuthenticationTypes.Token)
          ? true
          : false;
    }

    if (pName.text == "") {
      FocusScope.of(context).requestFocus(profileNameFocus);
    }

    Scaffold retBuild = Scaffold(
        appBar: AppBar(title: const Text("Prodi")),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: pName,
                      focusNode: profileNameFocus,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: "Profile Name",
                          icon: Icon(Icons.card_membership)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Profile Name';
                        }
                        return null;
                      },
                      onChanged: (val) => nameField = val,
                      onFieldSubmitted: (value) =>
                          FocusScope.of(context).requestFocus(profileURLFocus),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: pURL,
                      focusNode: profileURLFocus,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                          labelText: "URL", icon: Icon(Icons.link)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Profile URL';
                        }
                        return null;
                      },
                      onChanged: (val) => urlField = val,
                      onFieldSubmitted: (value) => FocusScope.of(context)
                          .requestFocus(profileUserNameFocus),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: pUserName,
                      focusNode: profileUserNameFocus,
                      decoration: const InputDecoration(
                          labelText: "UserName", icon: Icon(Icons.abc)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Profile UserName';
                        }
                        return null;
                      },
                      onChanged: (val) => usernameField = val,
                      onFieldSubmitted: (value) => FocusScope.of(context)
                          .requestFocus(profilePassWordFocus),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: pPassWord,
                      focusNode: profilePassWordFocus,
                      decoration: const InputDecoration(
                          labelText: "PassWord", icon: Icon(Icons.key)),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Profile PassWord';
                        }
                        return null;
                      },
                      onChanged: (val) => passwordField = val,
                      onFieldSubmitted: (value) => FocusScope.of(context)
                          .requestFocus(profileSyncMinutesFocus),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          "Enable Data Sync in Background",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        CupertinoSwitch(
                            value: isEnabled,
                            onChanged: (value) {
                              setState(() {
                                isEnabled = value;
                                if (profileEntry is Profile) {
                                  profileEntry.dataBackgroundSync =
                                      isEnabled ? 1 : 0;
                                }
                              });
                            }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: intervalMinutesController,
                      keyboardType: TextInputType.number,
                      focusNode: profileSyncMinutesFocus,
                      decoration: const InputDecoration(
                          labelText: "Data Synchronization Interval Minutes",
                          icon: Icon(Icons.key)),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            (int.tryParse(value) is! int)) {
                          return 'Please enter number of minutes';
                        }
                        return null;
                      },
                      onChanged: (val) => intervalMinsField =
                          int.tryParse(val) is int
                              ? int.parse(val)
                              : intervalMinsField,
                      onFieldSubmitted: (value) => FocusScope.of(context)
                          .requestFocus(profileCacheDaysFocus),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: pcacheDays,
                      keyboardType: TextInputType.number,
                      focusNode: profileCacheDaysFocus,
                      decoration: const InputDecoration(
                          labelText: "No of Days for data cache",
                          icon: Icon(Icons.abc)),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            (int.tryParse(value) is! int)) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onChanged: (val) => cacheDaysField =
                          int.tryParse(val) is int
                              ? int.parse(val)
                              : cacheDaysField,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField(
                      focusNode: profileAuthModeFocus,
                      decoration: const InputDecoration(
                          label: Text("Authentication Mode")),
                      items: ProdiAuthenticationTypes.values
                          .map((e) => DropdownMenuItem(
                                value: e.name,
                                child: Text(e.name),
                              ))
                          .toList(),
                      value: profileEntry is Profile
                          ? profileEntry.authMode.name
                          : ProdiAuthenticationTypes.Basic.name,
                      onChanged: (value) {
                        setState(() {
                          isRebuild = true;
                          authModeField = value.toString();
                          if (authModeField ==
                              ProdiAuthenticationTypes.Token.name) {
                            showAuthUrlfield = true;
                          } else {
                            showAuthUrlfield = false;
                            pAuthURL.text = "";
                          }
                        });
                      },
                    ),
                  ),
                  Visibility(
                    visible: showAuthUrlfield,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: pAuthURL,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                            labelText: "Authentication URL",
                            icon: Icon(Icons.token)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                        onChanged: (val) => cacheDaysField = int.parse(val),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var targetEntry;
                            if (profileEntry is Profile) {
                              profileEntry.name = pName.text;
                              profileEntry.url = pURL.text;
                              profileEntry.username = pUserName.text;
                              profileEntry.password = pPassWord.text;

                              targetEntry = profileEntry;
                            } else {
                              targetEntry = Profile(
                                  name: pName.text,
                                  url: pURL.text,
                                  username: pUserName.text,
                                  password: pPassWord.text);
                            }
                            targetEntry.dataBackgroundSyncIntervalMinutes =
                                int.parse(intervalMinutesController.text);
                            targetEntry.dataBackgroundSync = isEnabled ? 1 : 0;
                            if (targetEntry is Profile) {
                              targetEntry.dataBackgroundSync =
                                  isEnabled ? 1 : 0;
                              targetEntry.cacheDays = cacheDaysField;
                              targetEntry.authMode = ProdiAuthenticationTypes
                                  .values
                                  .where((element) =>
                                      element == targetEntry.authMode)
                                  .first;
                              if (targetEntry.authMode ==
                                  ProdiAuthenticationTypes.Token) {
                                targetEntry.authUrl = pAuthURL.text;
                              } else {
                                targetEntry.authUrl = "";
                              }
                            }

                            await Profile.KVStoreHook.writeRecord(targetEntry)
                                .then((value) =>
                                    ProfileProviderObj.buildProfileList().then(
                                        (value) =>
                                            Navigator.of(context).pop()));
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
