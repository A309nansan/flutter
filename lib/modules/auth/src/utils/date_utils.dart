import 'package:intl/intl.dart';

int calculateAge(DateTime birthDate) {
  final now = DateTime.now();
  int age = now.year - birthDate.year;
  if (now.month < birthDate.month ||
      (now.month == birthDate.month && now.day < birthDate.day)) {
    age--;
  }
  return age;
}

String convertDateTimeDisplay(String date) {
  final DateFormat displayFormatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  final DateFormat serverFormatter = DateFormat('yyyy-MM-dd');
  final DateTime displayDate = displayFormatter.parse(date);
  return serverFormatter.format(displayDate);
}