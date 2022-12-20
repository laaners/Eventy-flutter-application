import 'package:intl/intl.dart';

class DateFormatter {
  static String dateTime2String(DateTime date) {
    DateFormat f = DateFormat("yyyy-MM-dd HH:mm:ss");
    String stringDate = f.format(date);
    return stringDate;
  }

  static DateTime string2DateTime(String stringDate) {
    DateFormat f = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateTime objDate = f.parse(stringDate);
    return objDate;
  }

  static DateTime toUtcDateTime(DateTime localDate) {
    return localDate.toUtc();
  }

  static String toUtcString(String localDate) {
    DateFormat f = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateTime utcDate = f.parse(localDate).toUtc();
    return dateTime2String(utcDate);
  }

  static DateTime toLocalDateTime(DateTime utcDate) {
    return utcDate.toLocal();
  }

  static String toLocalString(String utcDate) {
    DateFormat f = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateTime localDate = f.parse(utcDate).toLocal();
    return dateTime2String(localDate);
  }
}
