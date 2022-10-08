import 'dart:developer';

class QueryKey {
  static String getQueryKeyFromDateTime(DateTime value) {
    value = value.toUtc();
    DateTime irisStartDate = DateTime(1840, 12, 31);
    String irisStartDateStr = "${irisStartDate.toString()}Z";
    irisStartDate = DateTime.parse(irisStartDateStr);
    int date = value.difference(irisStartDate).inDays;
    int time = Duration(
            hours: value.hour, minutes: value.minute, seconds: value.second)
        .inSeconds;
    return "${date.toString()}${time.toString().padLeft(5, "0")}";
  }

  static DateTime getDateTimeFromQueryKey(String value) {
    int pDays = int.parse(value.substring(0, 5));
    int pSeconds = int.parse(value.substring(5, 10));
    DateTime irisStartDate = DateTime(1840, 12, 31);
    DateTime targetDate = irisStartDate.add(Duration(days: pDays));
    targetDate = DateTime(targetDate.year, targetDate.month, targetDate.day)
        .add(Duration(seconds: pSeconds));
    String targetDateStr = "${targetDate.toString()}Z";
    targetDate = DateTime.parse(targetDateStr);
    return targetDate;
  }
}
