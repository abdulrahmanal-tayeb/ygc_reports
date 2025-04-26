import 'package:flutter/material.dart';


/// Returns the day name in arabic for the report (Because the report is not in Spanish!)
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

/// Returns the date in a formatted, and direction-aware form.
String formatDate(DateTime date, {bool reverseDirection = false}) {
  return reverseDirection? '${date.day} / ${date.month} / ${date.year}' : '${date.year} / ${date.month} / ${date.day}';
}

/// Returns the [time] in arabic readable format.
String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod; // convert 0 to 12
  final suffix = time.period == DayPeriod.am ? 'صباحا' : 'مساء';
  return '$hour $suffix';
}

/// Parses the time string [timeStr] and returns it as a [TimeOfDay]
TimeOfDay parseTime(String? timeStr) {
  if (timeStr == null) return const TimeOfDay(hour: 8, minute: 0);
  final parts = timeStr.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}