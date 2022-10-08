import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'package:prodeye/storage_apis/kv_store.dart';
import 'package:prodeye/logger/logger_levels.dart';

class ProdEyeSettings {
  static KVStore KVStoreHook = KVStore();
  final String id = "1";
  ProdiLogLevels logLevel = ProdiLogLevels.error;
  String supportEmail = "";
  int internalCacheServicePort = 6772;
  int screenDataRefreshIntervalSeconds = 10;
  int dataTaskIntervalMinutes = 1;
  int cacheTaskIntervalMinutes = 5;

  ProdEyeSettings(
      {required this.logLevel,
      required this.supportEmail,
      required this.internalCacheServicePort,
      required this.screenDataRefreshIntervalSeconds,
      required this.dataTaskIntervalMinutes,
      required this.cacheTaskIntervalMinutes});

  factory ProdEyeSettings.fromJson(dynamic record) {
    Map<String, dynamic> recordMap = Map<String, dynamic>.from(record);
    return ProdEyeSettings(
      logLevel: ProdiLogLevels.values.byName(recordMap["logLevel"]),
      supportEmail: recordMap["supportEmail"],
      internalCacheServicePort:
          int.parse(recordMap["internalCacheServicePort"].toString()),
      screenDataRefreshIntervalSeconds:
          int.parse(recordMap["screenDataRefreshIntervalSeconds"]),
      dataTaskIntervalMinutes: int.parse(recordMap["dataTaskIntervalMinutes"]),
      cacheTaskIntervalMinutes:
          int.parse(recordMap["cacheTaskIntervalMinutes"]),
    );
  }

  String inToJson() {
    Map<String, dynamic> ProdEyeSettingsMap = {
      "id": id,
      "logLevel": logLevel.name,
      "supportEmail": supportEmail,
      "internalCacheServicePort": internalCacheServicePort.toString(),
      "screenDataRefreshIntervalSeconds":
          screenDataRefreshIntervalSeconds.toString(),
      "dataTaskIntervalMinutes": dataTaskIntervalMinutes.toString(),
      "cacheTaskIntervalMinutes": cacheTaskIntervalMinutes.toString(),
    };
    return json.encode(ProdEyeSettingsMap);
  }

  static Future<ProdEyeSettings> getSettings() async {
    try {
      var record =
          await ProdEyeSettings.KVStoreHook.readById("ProdEyeSettings", "1");
      record = json.decode(record);
      return ProdEyeSettings.fromJson(record);
    } catch (error) {
      return ProdEyeSettings(
          logLevel: ProdiLogLevels.error,
          supportEmail: "",
          internalCacheServicePort: 6772,
          screenDataRefreshIntervalSeconds: 10,
          dataTaskIntervalMinutes: 1,
          cacheTaskIntervalMinutes: 5);
    }
  }

  static Future<String> getLocalPath() async {
    final directory = await getTemporaryDirectory();

    return directory.path;
  }
}
