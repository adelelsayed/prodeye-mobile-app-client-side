import 'package:prodeye/common_utils/query_key.dart';
import 'package:prodeye/models/model_abstract.dart';

class Logger extends ModelProdEye {
  int id = 0;
  int qKey = int.parse(QueryKey.getQueryKeyFromDateTime(DateTime.now()));
  DateTime logDate = DateTime.now().toUtc();
  String logType = "";
  String logModule = "LoggerItem";
  String logMessage = "";
  String logStackTrace = "";

  Logger(DateTime plogDate, String plogType, String plogModule,
      String plogMessage, String pStackTrace) {
    logType = plogType;
    logDate = plogDate.toUtc();
    logModule = plogModule;
    logMessage = plogMessage;
    logStackTrace = pStackTrace;
  }

  @override
  List<String> getsqlCreateTableStatement() {
    return [
      "CREATE TABLE ${this.runtimeType.toString()} (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, logDate TEXT, logType TEXT, logModule TEXT, logMessage TEXT, logStackTrace TEXT, qKey INTEGER);",
      "CREATE INDEX ${this.runtimeType.toString()}_TypeIndex ON ${this.runtimeType.toString()}(logType);",
      "CREATE INDEX ${this.runtimeType.toString()}_QkeyIndex ON ${this.runtimeType.toString()}(qKey);"
    ];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> retVal = {
      "logDate": logDate.toIso8601String(),
      "logType": logType,
      "logModule": logModule,
      "logMessage": logMessage,
      "logStackTrace": logStackTrace,
      "qKey": qKey
    };
    if (id != 0) {
      retVal["ID"] = id;
    }
    return retVal;
  }

  Logger.fromQueryMap(Map<String, dynamic> logMap) {
    id = int.parse(logMap["id"].toString());
    qKey = int.parse(logMap["qKey"].toString());
    logDate = DateTime.parse(logMap["logDate"].toString());
    logType = logMap["logType"].toString();
    logModule = logMap["logModule"].toString();
    logMessage = logMap["logMessage"].toString();
    logStackTrace = logMap["logStackTrace"].toString();
  }

  static Future<void> purge(int pQkey) async {
    List<Map<String, Object?>> querySet =
        await Logger.query("qKey", "<=", pQkey);
    List<Logger> objList = querySet.map((e) => Logger.fromQueryMap(e)).toList();
    for (var obj in objList) {
      await obj.delete("ID", "=");
    }
  }

  static Future<List<Map<String, Object?>>> query(
      String property, String operator, dynamic value) async {
    return ModelProdEye.query("Logger", property, operator, value);
  }

  static Future<List<Map<String, Object?>>> queryByPropertyList(
      List<String> properties,
      List<String> operators,
      List<dynamic> values) async {
    return ModelProdEye.queryByPropertyList(
        "Logger", properties, operators, values);
  }

  static Future<void> logMe(String type, String functionName, String message,
      {String sTackTrace = ""}) async {
    Logger currentLog =
        Logger(DateTime.now(), type, functionName, message, sTackTrace);
    await currentLog.save();
  }
}
