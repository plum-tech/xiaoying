import 'package:flutter/cupertino.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/l10n/time.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/timetable/entity/pos.dart';
import 'package:mimir/utils/error.dart';
import 'entity/timetable.dart';

import 'dart:math';

import 'i18n.dart';

import 'init.dart';

const maxWeekLength = 20;

Duration calcuSwitchAnimationDuration(num distance) {
  final time = sqrt(max(1, distance) * 100000);
  return Duration(milliseconds: time.toInt());
}

final _builtinStartDate = {
  (2016, Semester.term1): DateTime(2016, 8, 29),
  (2016, Semester.term2): DateTime(2017, 2, 20),
  (2017, Semester.term1): DateTime(2017, 9, 4),
  (2017, Semester.term2): DateTime(2018, 3, 5),
  (2018, Semester.term1): DateTime(2018, 9, 3),
  (2018, Semester.term2): DateTime(2019, 2, 25),
  (2019, Semester.term1): DateTime(2019, 9, 2),
  (2019, Semester.term2): DateTime(2020, 2, 24),
  (2020, Semester.term1): DateTime(2020, 9, 14),
  (2020, Semester.term2): DateTime(2021, 3, 1),
  (2021, Semester.term1): DateTime(2021, 9, 6),
  (2021, Semester.term2): DateTime(2022, 2, 14),
  (2022, Semester.term1): DateTime(2022, 9, 5),
  (2022, Semester.term2): DateTime(2023, 2, 6),
  (2023, Semester.term1): DateTime(2023, 9, 18),
  (2023, Semester.term2): DateTime(2024, 2, 26),
  (2024, Semester.term1): DateTime(2024, 9, 2),
};

DateTime estimateStartDate(int year, Semester semester) {
  final builtin = _builtinStartDate[(year, semester)];
  if (builtin != null) return builtin;
  if (semester == Semester.term1) {
    return findFirstWeekdayInCurrentMonth(DateTime(year, 9), DateTime.monday);
  } else {
    return findFirstWeekdayInCurrentMonth(DateTime(year + 1, 2), DateTime.monday);
  }
}

DateTime findFirstWeekdayInCurrentMonth(DateTime current, int weekday) {
  // Calculate the first day of the current month while keeping the same year.
  DateTime firstDayOfMonth = DateTime(current.year, current.month, 1);

  // Calculate the difference in days between the first day of the current month
  // and the desired weekday.
  int daysUntilWeekday = (weekday - firstDayOfMonth.weekday + 7) % 7;

  // Calculate the date of the first occurrence of the desired weekday in the current month.
  DateTime firstWeekdayInMonth = firstDayOfMonth.add(Duration(days: daysUntilWeekday));

  return firstWeekdayInMonth;
}

Future<DateTime?> fetchStartDateOfCurrentSemester(SemesterInfo selected, OaUserType? userType) async {
  try {
    if (userType == OaUserType.undergraduate) {
      final current = estimateSemesterInfo();
      if (selected == current) {
        final span = await TimetableInit.service.getUgSemesterSpan();
        if (span != null) {
          return span.start;
        }
      }
    }
  } catch (error, stackTrace) {
    debugPrintError(error, stackTrace);
    return null;
  }
  return null;
}

Future<int?> selectWeekInTimetable({
  required BuildContext context,
  required Timetable timetable,
  int? initialWeekIndex,
  required String submitLabel,
}) async {
  final todayPos = timetable.locate(DateTime.now());
  final todayIndex = todayPos.weekIndex;
  final controller = FixedExtentScrollController(initialItem: initialWeekIndex ?? todayIndex);
  final selectedWeek = await context.showPicker(
        count: 20,
        controller: controller,
        ok: submitLabel,
        okDefault: true,
        actions: [
          (ctx, curSelected) => CupertinoActionSheetAction(
                onPressed: () {
                  controller.animateToItem(todayIndex,
                      duration: const Duration(milliseconds: 500), curve: Curves.fastEaseInToSlowEaseOut);
                },
                child: i18n.findToday.text(),
              )
        ],
        make: (ctx, i) {
          return Text(i18n.weekOrderedName(number: i + 1));
        },
      ) ??
      initialWeekIndex;
  controller.dispose();
  return selectedWeek;
}

Future<TimetablePos?> selectDayInTimetable({
  required BuildContext context,
  required Timetable timetable,
  TimetablePos? initialPos,
  required String submitLabel,
}) async {
  final initialWeekIndex = initialPos?.weekIndex;
  final initialDayIndex = initialPos?.weekday.index;
  final todayPos = timetable.locate(DateTime.now());
  final todayWeekIndex = todayPos.weekIndex;
  final todayDayIndex = todayPos.weekday.index;
  final $week = FixedExtentScrollController(initialItem: initialPos?.weekIndex ?? todayWeekIndex);
  final $day = FixedExtentScrollController(initialItem: initialDayIndex ?? todayDayIndex);
  final (selectedWeek, selectedDay) = await context.showDualPicker(
        countA: 20,
        countB: 7,
        controllerA: $week,
        controllerB: $day,
        ok: submitLabel,
        okDefault: true,
        okEnabled: (weekSelected, daySelected) => weekSelected != initialWeekIndex || daySelected != initialDayIndex,
        actions: [
          (ctx, week, day) => CupertinoActionSheetAction(
                onPressed: () {
                  $week.animateToItem(todayWeekIndex,
                      duration: const Duration(milliseconds: 500), curve: Curves.fastEaseInToSlowEaseOut);

                  $day.animateToItem(todayDayIndex,
                      duration: const Duration(milliseconds: 500), curve: Curves.fastEaseInToSlowEaseOut);
                },
                child: i18n.findToday.text(),
              )
        ],
        makeA: (ctx, i) => i18n.weekOrderedName(number: i + 1).text(),
        makeB: (ctx, i) => Weekday.fromIndex(i).l10n().text(),
      ) ??
      (initialWeekIndex, initialDayIndex);
  $week.dispose();
  $day.dispose();
  return selectedWeek != null && selectedDay != null
      ? TimetablePos(weekIndex: selectedWeek, weekday: Weekday.fromIndex(selectedDay))
      : null;
}
