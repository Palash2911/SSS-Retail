import 'package:intl/intl.dart';

String getDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

String formatUnixDate(String dateU) {
  final dateInMilliseconds = int.parse(dateU);
  final date = DateTime.fromMillisecondsSinceEpoch(dateInMilliseconds);
  final formattedDate = DateFormat('d MMM, y').format(date);
  final daySuffix = getDaySuffix(date.day);
  final finalFormattedDate =
      '${date.day}$daySuffix ${formattedDate.substring(2)}';
  return finalFormattedDate;
}

String formatUnixTime(String unixTimestamp) {
  final dateInMilliseconds = int.parse(unixTimestamp);
  final dateTime = DateTime.fromMillisecondsSinceEpoch(dateInMilliseconds);
  final formattedTime = DateFormat('hh:mm a').format(dateTime);
  return formattedTime;
}
