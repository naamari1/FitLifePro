import 'package:intl/intl.dart';

class Utils {
  static String toDate(DateTime date) {
    final dateTime = DateFormat.yMMMEd().format(date);
    return dateTime;
  }

  static String toTime(DateTime date) {
    final dateTime = DateFormat.Hm().format(date);
    return dateTime;
  }
}
