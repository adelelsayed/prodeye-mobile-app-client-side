import 'dart:developer';

import 'package:prodeye/models/model_abstract.dart';
import 'package:prodeye/query_managers/component.dart';
import 'package:prodeye/models/profile.dart';

class Production extends ModelProdEye {
  int id = 0;
  String name = "";
  String status = "";
  DateTime statusAsOf = DateTime.now();
  late Profile profileParent;
  late ComponentQuery components;
  bool showErrorNotification = true;
  bool showWarningrNotification = true;
  bool showAlertNotification = true;
  bool showJobNotification = true;
  bool showQueueNotification = true;

  Production(String pName, String pStatus, String pStatusAsOf) {
    name = pName;
    status = pStatus;
    statusAsOf = DateTime.parse("$pStatusAsOf");
  }

  @override
  List<String> getsqlCreateTableStatement() {
    return [
      "CREATE TABLE ${this.runtimeType.toString()} (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, status TEXT, statusAsOf TEXT, profileParent TEXT,showErrorNotification INTEGER,showWarningrNotification INTEGER,showAlertNotification INTEGER,showJobNotification INTEGER,showQueueNotification INTEGER);",
      "CREATE INDEX ${this.runtimeType.toString()}_StatusIndex ON ${this.runtimeType.toString()}(status);",
      "CREATE INDEX ${this.runtimeType.toString()}_ProfileIndex ON ${this.runtimeType.toString()}(profileParent);"
    ];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> retVal = {
      "name": name,
      "status": status,
      "statusAsOf": statusAsOf.toIso8601String(),
      "profileParent": profileParent.id,
      "showErrorNotification": showErrorNotification ? 1 : 0,
      "showWarningrNotification": showWarningrNotification ? 1 : 0,
      "showAlertNotification": showAlertNotification ? 1 : 0,
      "showJobNotification": showJobNotification ? 1 : 0,
      "showQueueNotification": showQueueNotification ? 1 : 0,
    };
    if (id != 0) {
      retVal["ID"] = id;
    }
    return retVal;
  }

  Production.fromQueryMap(Map<String, dynamic> prodMap) {
    id = prodMap["ID"];
    name = prodMap["name"];
    status = prodMap["status"];
    statusAsOf = prodMap["statusAsOf"];
    showErrorNotification =
        prodMap["showErrorNotification"] == 1 ? true : false;
    showWarningrNotification =
        prodMap["showWarningrNotification"] == 1 ? true : false;
    showAlertNotification =
        prodMap["showAlertNotification"] == 1 ? true : false;
    showJobNotification = prodMap["showJobNotification"] == 1 ? true : false;
    showQueueNotification =
        prodMap["showQueueNotification"] == 1 ? true : false;
  }

  static Future<List<Map<String, Object?>>> query(
      String property, String operator, dynamic value) async {
    return ModelProdEye.query("Production", property, operator, value);
  }

  static Future<List<Map<String, Object?>>> queryByPropertyList(
      List<String> properties,
      List<String> operators,
      List<dynamic> values) async {
    return ModelProdEye.queryByPropertyList(
        "Production", properties, operators, values);
  }

  static Future<Production> getOrCreate(
      Map<String, dynamic> entryMap,
      dynamic parent,
      List<String> properties,
      List<String> operators,
      List<dynamic> values) async {
    List<Map<String, Object?>> existing =
        await Production.queryByPropertyList(properties, operators, values);

    Production Obj = existing.isEmpty
        ? Production(
            entryMap["Name"], entryMap["Status"], entryMap["StatusAsOf"])
        : Production(
            existing[0]["name"].toString(),
            existing[0]["status"].toString(),
            existing[0]["statusAsOf"].toString());
    Obj.profileParent = parent;
    if (existing.isNotEmpty) {
      Obj.id = int.parse(existing[0]["ID"].toString());
      Obj.showAlertNotification =
          int.parse(existing[0]["showAlertNotification"].toString()) == 1
              ? true
              : false;
      Obj.showWarningrNotification =
          int.parse(existing[0]["showWarningrNotification"].toString()) == 1
              ? true
              : false;
      Obj.showJobNotification =
          int.parse(existing[0]["showJobNotification"].toString()) == 1
              ? true
              : false;
      Obj.showErrorNotification =
          int.parse(existing[0]["showErrorNotification"].toString()) == 1
              ? true
              : false;
      Obj.showQueueNotification =
          int.parse(existing[0]["showQueueNotification"].toString()) == 1
              ? true
              : false;
      Obj.update("ID", "=");
    } else {
      Obj.id = await Obj.save();
    }
    return Obj;
  }
}
