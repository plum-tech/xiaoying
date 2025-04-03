import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mimir/l10n/time.dart';
import 'package:mimir/school/utils.dart';
import 'package:rettulf/rettulf.dart';

Color? getTimetableHeaderColor(
  BuildContext context, {
  bool selected = false,
}) {
  if (selected) {
    return context.colorScheme.secondaryContainer;
  }
  return null;
}

Color? getTimetableHeaderDashLinedColor(
  BuildContext context,
) {
  return context.colorScheme.surfaceTint.withOpacity(0.35);
}

class TimetableHeader extends StatelessWidget {
  final int weekIndex;
  final Weekday? selectedWeekday;
  final Function(Weekday dayIndex)? onDayTap;
  final DateTime startDate;

  const TimetableHeader({
    super.key,
    required this.weekIndex,
    required this.startDate,
    this.selectedWeekday,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = reflectWeekDayIndexToDate(
      weekIndex: weekIndex,
      weekday: Weekday.monday,
      startDate: startDate,
    );
    final onDayTap = this.onDayTap;

    return [
      Container(
        decoration: BoxDecoration(
          color: getTimetableHeaderColor(context),
        ),
        child: MonthHeaderCellTextBox(
          month: date.month,
        ),
      ).expanded(),
      ...Weekday.monday.genSequenceStartWithThis().map((weekday) {
        return Expanded(
          child: InkWell(
            onTap: onDayTap != null
                ? () {
                    onDayTap.call(weekday);
                  }
                : null,
            child: HeaderCell(
              weekIndex: weekIndex,
              weekday: weekday,
              startDate: startDate,
              selected: weekday == selectedWeekday,
            ),
          ),
        );
      }),
    ].toList().row(maa: MainAxisAlignment.spaceEvenly);
  }
}

class HeaderCell extends StatelessWidget {
  final int weekIndex;
  final Weekday weekday;
  final DateTime startDate;
  final bool selected;

  const HeaderCell({
    super.key,
    required this.weekIndex,
    required this.weekday,
    required this.startDate,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Durations.short2,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: getTimetableHeaderColor(context, selected: selected),
      ),
      child: HeaderCellTextBox(
        weekIndex: weekIndex,
        weekday: weekday,
        startDate: startDate,
      ),
    );
  }
}

class HeaderCellTextBox extends StatelessWidget {
  final int weekIndex;
  final Weekday weekday;
  final DateTime startDate;

  const HeaderCellTextBox({
    super.key,
    required this.weekIndex,
    required this.weekday,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final date = reflectWeekDayIndexToDate(
      weekIndex: weekIndex,
      weekday: weekday,
      startDate: startDate,
    );
    final firstDateInWeek = reflectWeekDayIndexToDate(
      startDate: startDate,
      weekIndex: weekIndex,
      weekday: Weekday.monday,
    );
    final day = date.month == firstDateInWeek.month || date.day != 1
        ? "${date.day}"
        : DateFormat("MMM", context.locale.toString()).format(DateTime(0, date.month));
    return CustomHeaderCellTextBox(
      line1: weekday.l10nShort(),
      line2: day,
    );
  }
}

final _monthAbbr = DateFormat("MMM");

class MonthHeaderCellTextBox extends StatelessWidget {
  final int month;

  const MonthHeaderCellTextBox({
    super.key,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    if (context.locale.languageCode == "zh") {
      return CustomHeaderCellTextBox(
        line1: "$month",
        line2: "月",
      );
    }
    return CustomHeaderCellTextBox(
      line1: "",
      line2: _monthAbbr.format(DateTime(0, month)),
    );
  }
}

class CustomHeaderCellTextBox extends StatelessWidget {
  final String line1;
  final String line2;

  const CustomHeaderCellTextBox({
    super.key,
    required this.line1,
    required this.line2,
  });

  @override
  Widget build(BuildContext context) {
    return [
      line1.text(
        textAlign: TextAlign.center,
        style: context.textTheme.titleSmall,
        maxLines: 1,
      ),
      line2.text(
        textAlign: TextAlign.center,
        style: context.textTheme.labelSmall,
        maxLines: 1,
      ),
    ].column().padOnly(t: 5, b: 5);
  }
}
