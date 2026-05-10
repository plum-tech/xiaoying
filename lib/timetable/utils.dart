import 'package:mimir/school/entity/school.dart';

import 'dart:math';

const maxWeekLength = 20;

Duration calcuSwitchAnimationDuration(num distance) {
  final time = sqrt(max(1, distance) * 100000);
  return Duration(milliseconds: time.toInt());
}

DateTime estimateStartDate(int year, Semester semester) {
  if (semester == Semester.term1) {
    return findFirstWeekdayInCurrentMonth(DateTime(year, 9), DateTime.monday);
  } else {
    return findFirstWeekdayInCurrentMonth(
      DateTime(year + 1, 2),
      DateTime.monday,
    );
  }
}

DateTime findFirstWeekdayInCurrentMonth(DateTime current, int weekday) {
  // Calculate the first day of the current month while keeping the same year.
  DateTime firstDayOfMonth = DateTime(current.year, current.month, 1);

  // Calculate the difference in days between the first day of the current month
  // and the desired weekday.
  int daysUntilWeekday = (weekday - firstDayOfMonth.weekday + 7) % 7;

  // Calculate the date of the first occurrence of the desired weekday in the current month.
  DateTime firstWeekdayInMonth = firstDayOfMonth.add(
    Duration(days: daysUntilWeekday),
  );

  return firstWeekdayInMonth;
}
