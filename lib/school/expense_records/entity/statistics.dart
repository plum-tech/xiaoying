import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/lifecycle.dart';
import 'package:mimir/utils/date.dart';

import 'local.dart';

typedef StartTime2Records = List<({DateTime start, List<Transaction> records})>;

enum StatisticsMode {
  day,
  week,
  month,
  year;

  StatisticsMode get downgrade {
    if (this == day) throw RangeError.range(0, 1, StatisticsMode.values.length);
    return StatisticsMode.values[index - 1];
  }

  const StatisticsMode();

  /// Resort the records, separate them by start time, and sort them in DateTime ascending order.
  StartTime2Records resort(List<Transaction> records) {
    switch (this) {
      case StatisticsMode.day:
        final d2records = records.groupListsBy((r) => (r.timestamp.year, r.timestamp.month, r.timestamp.day));
        final startTime2Records = d2records.entries
            .map((entry) => (start: DateTime(entry.key.$1, entry.key.$2, entry.key.$3), records: entry.value))
            .toList();
        startTime2Records.sortBy((r) => r.start);
        return startTime2Records;
      case StatisticsMode.week:
        final ym2records = records.groupListsBy((r) => (r.timestamp.year, r.timestamp.week));
        final startTime2Records = ym2records.entries
            .map((entry) =>
                (start: getDateOfFirstDayInWeek(year: entry.key.$1, week: entry.key.$2), records: entry.value))
            .toList();
        startTime2Records.sortBy((r) => r.start);
        return startTime2Records;
      case StatisticsMode.month:
        final ym2records = records.groupListsBy((r) => (r.timestamp.year, r.timestamp.month));
        final startTime2Records = ym2records.entries
            .map((entry) => (start: DateTime(entry.key.$1, entry.key.$2), records: entry.value))
            .toList();
        startTime2Records.sortBy((r) => r.start);
        return startTime2Records;
      case StatisticsMode.year:
        final ym2records = records.groupListsBy((r) => r.timestamp.year);
        final startTime2Records =
            ym2records.entries.map((entry) => (start: DateTime(entry.key), records: entry.value)).toList();
        startTime2Records.sortBy((r) => r.start);
        return startTime2Records;
    }
  }

  DateTime getAfterUnitTime({
    required DateTime start,
    DateTime? endLimit,
  }) {
    var end = switch (this) {
      StatisticsMode.day => start.copyWith(
          day: start.day,
          hour: 23,
          minute: 59,
          second: 59,
        ),
      StatisticsMode.week => start.copyWith(
          day: start.day + 6,
          hour: 23,
          minute: 59,
          second: 59,
        ),
      StatisticsMode.month => start.copyWith(
          day: daysInMonth(year: start.month, month: start.month),
          hour: 23,
          minute: 59,
          second: 59,
        ),
      StatisticsMode.year => start.copyWith(
          month: 12,
          day: daysInMonth(year: start.month, month: start.month),
          hour: 23,
          minute: 59,
          second: 59,
        )
    };
    if (endLimit != null && endLimit.isBefore(end)) {
      end = endLimit;
    }
    return end;
  }

  String formatDate(DateTime date) {
    final local = $key.currentContext?.locale.toString();
    return switch (this) {
      StatisticsMode.day => DateFormat.MMMMd(local).format(date),
      StatisticsMode.week => DateFormat.MMMMd(local).format(date),
      StatisticsMode.month => DateFormat.MMMMd(local).format(date),
      StatisticsMode.year => DateFormat.MMMM(local).format(date),
    };
  }

  String l10nName() => "expenseRecords.statsMode.$name".tr();
}
