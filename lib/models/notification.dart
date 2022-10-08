import 'dart:developer';

import 'package:prodeye/models/model_abstract.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prodeye/notification_service/notify_plugin_interface.dart';

class ProdiNotification extends ModelProdEye {
  int ID = 0;
  String prodeyeObjType;
  int prodeyeObjId;
  String title;
  String body;
  String payload = "";
  bool shown = false;
  int qKey;

  ProdiNotification(
      {required this.title,
      required this.body,
      required this.prodeyeObjId,
      required this.prodeyeObjType,
      required this.qKey});

  @override
  List<String> getsqlCreateTableStatement() {
    return [
      "CREATE TABLE ${this.runtimeType.toString()} (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, prodeyeObjType TEXT, prodeyeObjId INTEGER,title TEXT,body TEXT,payload TEXT,shown INTEGER, qKey INTEGER);",
      "CREATE INDEX ${this.runtimeType.toString()}_TypeIndex ON ${this.runtimeType.toString()}(prodeyeObjType);",
      "CREATE INDEX ${this.runtimeType.toString()}_ShownIndex ON ${this.runtimeType.toString()}(shown);",
      "CREATE INDEX ${this.runtimeType.toString()}_QkeyIndex ON ${this.runtimeType.toString()}(qKey);",
      "CREATE INDEX ${this.runtimeType.toString()}_QkeyShownIndex ON ${this.runtimeType.toString()}(qKey,shown);"
    ];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> retVal = {
      "prodeyeObjType": prodeyeObjType,
      "prodeyeObjId": prodeyeObjId,
      "title": title,
      "body": body,
      "payload": payload,
      "shown": shown ? 1 : 0,
      "qKey": qKey,
    };
    if (ID != 0) {
      retVal["ID"] = ID;
    }
    return retVal;
  }

  @override
  Future<int> save({String conflictResolve = ""}) async {
    ID = await super.save();
    payload =
        "{\"type\":$prodeyeObjType , \"id\": $prodeyeObjId, \"notificationId\":$ID }";
    await update("ID", "=");
    return ID;
  }

  factory ProdiNotification.fromQueryMap(Map<String, dynamic> notiMap) {
    int pID = int.parse(notiMap["ID"].toString());
    String pprodeyeObjType = notiMap["prodeyeObjType"];
    int pprodeyeObjId = int.parse(notiMap["prodeyeObjId"].toString());
    String ptitle = notiMap["title"];
    String pbody = notiMap["body"];
    String ppayload = notiMap["payload"];
    bool pshown = int.parse(notiMap["shown"].toString()) == 1 ? true : false;
    int pQkey = int.parse(notiMap["qKey"].toString());
    ProdiNotification obj = ProdiNotification(
        title: ptitle,
        body: pbody,
        prodeyeObjId: pprodeyeObjId,
        prodeyeObjType: pprodeyeObjType,
        qKey: pQkey);
    obj.ID = pID;
    obj.shown = pshown;
    obj.payload = ppayload;
    return obj;
  }

  static Future<void> purge(int pQkey) async {
    List<Map<String, Object?>> querySet =
        await ProdiNotification.query("qKey", "<=", pQkey);
    List<ProdiNotification> objList =
        querySet.map((e) => ProdiNotification.fromQueryMap(e)).toList();
    for (var obj in objList) {
      await obj.delete("ID", "=");
    }
  }

  static Future<List<Map<String, Object?>>> query(
      String property, String operator, dynamic value) async {
    return ModelProdEye.query("ProdiNotification", property, operator, value);
  }

  static Future<List<Map<String, Object?>>> queryByPropertyList(
      List<String> properties,
      List<String> operators,
      List<dynamic> values) async {
    return ModelProdEye.queryByPropertyList(
        "ProdiNotification", properties, operators, values);
  }

  Future<void> show(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      NotificationDetails notifDetails) async {
    await flutterLocalNotificationsPlugin.show(
        ID, title.replaceAll("^", " "), body, notifDetails,
        payload: payload);
  }

  Future<void> updateAsShown() async {
    if (!shown) {
      shown = true;
      await update("ID", "=");
    }
  }
}
