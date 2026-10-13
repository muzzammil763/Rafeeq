import 'package:hijri/hijri_calendar.dart';

class RamadanDayInfo {
  final DateTime date;
  final HijriCalendar hijriDate;
  final DateTime suhoor;
  final DateTime iftar;

  RamadanDayInfo({
    required this.date,
    required this.hijriDate,
    required this.suhoor,
    required this.iftar,
  });
}
