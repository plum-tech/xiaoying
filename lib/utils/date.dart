bool isLeapYear(int year) {
  if (year % 400 == 0) return true;
  if (year % 4 == 0 && year % 100 != 0) return true;
  return false;
}

int daysInMonth({required int year, required int month}) {
  assert(1 <= month && month <= 12, "month must be in [1,12]");
  return switch (month) {
    1 => 31,
    2 => isLeapYear(year) ? 29 : 28,
    3 => 31,
    4 => 30,
    5 => 31,
    6 => 30,
    7 => 31,
    8 => 31,
    9 => 30,
    10 => 31,
    11 => 30,
    12 => 31,
    _ => 30,
  };
}

int daysPastInYear({required int year, required int month, required int day}) {
  var totalMonthLength = 0;
  for (var count = 1; count < month; count++) {
    totalMonthLength += daysInMonth(month: count, year: year);
  }
  return totalMonthLength + day;
}

int getWeek({required int year, required int month, required int day}) {
  double a = (daysPastInYear(year: year, month: month, day: day) / 7) + 1;
  return a.toInt();
}

extension DateTimeX on DateTime {
  int get week => getWeek(year: year, month: month, day: day);

  int get calendarOrderWeekday {
    final w = weekday;
    return w == DateTime.sunday ? 0 : w;
  }

  bool inTheSameDay(DateTime b) {
    return year == b.year && month == b.month && day == b.day;
  }
}

String formatChineseDate(DateTime date) {
  return "${date.year}年${date.month}月${date.day}日";
}
