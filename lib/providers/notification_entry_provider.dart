import 'package:flutter/cupertino.dart';

import 'package:prodeye/models/notification.dart';

class PordiNotificationEntryProvider with ChangeNotifier {
  ProdiNotification notif;
  PordiNotificationEntryProvider({required this.notif});

  Future<void> updateAsShown() async {
    await notif.updateAsShown();
    notifyListeners();
  }
}
