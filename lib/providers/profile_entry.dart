import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:prodeye/models/profile.dart';

class ProfileEntryProvider with ChangeNotifier {
  Profile currentProfile;
  ProfileEntryProvider({required this.currentProfile});
  Future<void> loadDataByDateTimeFrame(
      DateTime datefrom, DateTime dateto) async {
    if (!locked) {
      locked = true;
      await currentProfile.loadDataByDateTimeFrame(datefrom, dateto);
      notifyListeners();
      locked = false;
    }
  }

  bool _locked = false;
  set locked(bool lck) {
    _locked = lck;
  }

  bool get locked {
    return _locked;
  }
}
