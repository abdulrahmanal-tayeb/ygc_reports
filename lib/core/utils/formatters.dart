import 'package:flutter/material.dart';

String getDayName(DateTime date){
  const arabicDays = {
    DateTime.saturday: 'السبت',
    DateTime.sunday: 'الأحد',
    DateTime.monday: 'الاثنين',
    DateTime.tuesday: 'الثلاثاء',
    DateTime.wednesday: 'الأربعاء',
    DateTime.thursday: 'الخميس',
    DateTime.friday: 'الجمعة',
  };

  return arabicDays[date.weekday] ?? '';
}

String formatDate(DateTime date, {bool reverseDirection = false}) {
  return reverseDirection? '${date.day} / ${date.month} / ${date.year}' : '${date.year} / ${date.month} / ${date.day}';
}

String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod; // convert 0 to 12
  final suffix = time.period == DayPeriod.am ? 'صباحا' : 'مساء';
  return '$hour $suffix';
}

TimeOfDay parseTime(String? timeStr) {
  if (timeStr == null) return const TimeOfDay(hour: 8, minute: 0);
  final parts = timeStr.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}