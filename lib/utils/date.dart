import 'package:mimir/utils/weekday.dart';

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

int daysInYear(int year) {
  return isLeapYear(year) ? 366 : 365;
}

List<int> daysInEachMonth({required int year}) {
  return [
    31,
    isLeapYear(year) ? 29 : 28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
  ];
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

DateTime getDateOfFirstDayInWeek({required int year, required int week}) {
  final day = (week - 1) * 7;
  return DateTime(year, 1, day);
}

String formatDateSpan({
  required DateTime from,
  required DateTime to,
  bool showYear = true,
}) {
  if (from.inTheSameDay(to)) {
    return showYear ? formatChineseDate(from) : formatChineseMonthDay(from);
  }

  if (from.year == to.year) {
    if (from.month == to.month) {
      return showYear
          ? "${from.year}年${from.month}月${from.day}日-${to.day}日"
          : "${from.month}月${from.day}日-${to.day}日";
    }
    return showYear
        ? "${from.year}年${from.month}月${from.day}日-${to.month}月${to.day}日"
        : "${from.month}月${from.day}日-${to.month}月${to.day}日";
  }

  if (showYear) {
    return "${formatChineseDate(from)}-${formatChineseDate(to)}";
  }

  return "${formatChineseMonthDay(from)}-${formatChineseMonthDay(to)}";
}

int dateTimeComparator(DateTime? timeA, DateTime? timeB) {
  if (timeA == null || timeB == null) {
    if (timeA != timeB) {
      return timeA == null ? 1 : -1;
    }
    return 0;
  }
  return timeA.isAfter(timeB) ? 1 : -1;
}

String formatChineseYearMonth(DateTime date) {
  return "${date.year}年${date.month}月";
}

String formatChineseDate(DateTime date) {
  return "${date.year}年${date.month}月${date.day}日";
}

String formatChineseMonthDay(DateTime date) {
  return "${date.month}月${date.day}日";
}

String formatChineseDateWithWeekday(DateTime date) {
  final weekday = Weekday.fromIndex(date.weekday - DateTime.monday);
  return "${formatChineseDate(date)} ${weekday.label}";
}
