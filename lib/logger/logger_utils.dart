import 'dart:developer';

import 'package:prodeye/logger/logger.dart';
import 'package:prodeye/logger/logger_levels.dart';

class ProdiLog {
  static Future<void> debug(
      ProdiLogLevels appLogLevel, String functionName, String message,
      {String stackTrace = ""}) async {
    if (appLogLevel.index == 4) {
      await Logger.logMe("D", functionName, message, sTackTrace: stackTrace);
    }
  }

  static Future<void> info(
      ProdiLogLevels appLogLevel, String functionName, String message,
      {String stackTrace = ""}) async {
    if (appLogLevel.index <= 3) {
      await Logger.logMe("I", functionName, message, sTackTrace: stackTrace);
    }
  }

  static Future<void> warn(
      ProdiLogLevels appLogLevel, String functionName, String message,
      {String stackTrace = ""}) async {
    if (appLogLevel.index <= 2) {
      await Logger.logMe("W", functionName, message, sTackTrace: stackTrace);
    }
  }

  static Future<void> error(
      ProdiLogLevels appLogLevel, String functionName, String message,
      {String stackTrace = ""}) async {
    if (appLogLevel.index <= 1) {
      await Logger.logMe("E", functionName, message, sTackTrace: stackTrace);
    }
  }

  static Future<void> fatal(
      ProdiLogLevels appLogLevel, String functionName, String message,
      {String stackTrace = ""}) async {
    if (appLogLevel.index <= 0) {
      await Logger.logMe("F", functionName, message, sTackTrace: stackTrace);
    }
  }
}
