import 'dart:developer';

import 'package:prodeye/models/model_abstract.dart';
import 'package:prodeye/models/production.dart';
import 'package:prodeye/query_managers/component_job.dart';
import 'package:prodeye/query_managers/component_log.dart';
import 'package:prodeye/query_managers/component_queue_and_messages.dart';

class Component extends ModelProdEye {
  int id = 0;
  late Production ProductionParent;
  String name = "";
  String type = "";
  late ComponentJobQuery jobs;
  late ComponentQueueMessageStatsQuery queMessages;
  late ComponentErrors errors;
  late ComponentWarnings warnings;
  late ComponentAlerts alerts;

  Component({required this.name, required this.type});

  @override
  List<String> getsqlCreateTableStatement() {
    return [
      "CREATE TABLE ${this.runtimeType.toString()} (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, comptype TEXT,productionParent INTEGER,FOREIGN KEY(productionParent) REFERENCES Production(id) );",
      "CREATE INDEX ${this.runtimeType.toString()}_TypeIndex ON ${this.runtimeType.toString()}(comptype);",
      "CREATE INDEX ${this.runtimeType.toString()}_ParentIndex ON ${this.runtimeType.toString()}(productionParent);",
      "CREATE INDEX ${this.runtimeType.toString()}_ParentTypeIndex ON ${this.runtimeType.toString()}(productionParent,comptype);"
    ];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> retVal = {
      "name": name,
      "comptype": type,
      "productionParent": ProductionParent.id
    };
    if (id != 0) {
      retVal["ID"] = id;
    }
    return retVal;
  }

  static Future<List<Map<String, Object?>>> query(
      String property, String operator, dynamic value) async {
    return ModelProdEye.query("Component", property, operator, value);
  }

  static Future<List<Map<String, Object?>>> queryByPropertyList(
      List<String> properties,
      List<String> operators,
      List<dynamic> values) async {
    return ModelProdEye.queryByPropertyList(
        "Component", properties, operators, values);
  }

  static Future<Component> getOrCreate(
      Map<String, dynamic> entryMap,
      dynamic parent,
      List<String> properties,
      List<String> operators,
      List<dynamic> values) async {
    List<Map<String, Object?>> existing =
        await Component.queryByPropertyList(properties, operators, values);

    Component Obj = existing.isEmpty
        ? Component(name: entryMap["Name"], type: entryMap["Type"])
        : Component(
            name: existing[0]["name"].toString(),
            type: existing[0]["comptype"].toString(),
          );

    Obj.ProductionParent = parent;
    if (existing.isNotEmpty) {
      Obj.id = int.parse(existing[0]["ID"].toString());

      Obj.update("ID", "=");
    } else {
      Obj.id = await Obj.save();
    }

    return Obj;
  }
}
