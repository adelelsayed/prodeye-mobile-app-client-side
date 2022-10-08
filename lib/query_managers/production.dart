import 'dart:convert';
import 'dart:developer';
import 'package:prodeye/models/production.dart';
import 'package:prodeye/models/profile.dart';
import 'package:prodeye/query_managers/component.dart';
import 'package:prodeye/query_managers/query_manager.dart';

class ProductionQuery extends QueryManager {
  List<Production> productions = [];
  ProductionQuery(String pParentId) {
    parentId = pParentId;
  }
  @override
  Future<void> prepare(var parentObject) async {
    if (!isPrepared) {
      List<Map<String, Object?>> rawProductions =
          await Production.query("profileParent", "=", parentId);

      for (Map<String, Object?> prod in rawProductions) {
        Production productn = Production(prod["name"].toString(),
            prod["status"].toString(), prod["statusAsOf"].toString());
        productn.id = int.parse(prod["ID"].toString());
        dynamic rawProfile =
            await Profile.KVStoreHook.readById("Profile", parentId);
        Profile parentProfileObj = Profile.fromJson(json.decode(rawProfile));
        productn.profileParent = parentObject;
        productn.showErrorNotification =
            int.parse(prod["showErrorNotification"].toString()) == 1
                ? true
                : false;
        productn.showWarningrNotification =
            int.parse(prod["showWarningrNotification"].toString()) == 1
                ? true
                : false;
        productn.showAlertNotification =
            int.parse(prod["showAlertNotification"].toString()) == 1
                ? true
                : false;
        productn.showJobNotification =
            int.parse(prod["showJobNotification"].toString()) == 1
                ? true
                : false;
        productn.showQueueNotification =
            int.parse(prod["showQueueNotification"].toString()) == 1
                ? true
                : false;
        productn.components = ComponentQuery(productn.id.toString());
        await productn.components.prepare(productn);
        productions.add(productn);
      }
      isPrepared = true;
    }
  }
}
