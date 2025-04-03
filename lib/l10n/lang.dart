import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:mimir/l10n/time.dart';
import 'package:mimir/r.dart';

abstract class RegionalFormatter {
  DateFormat get hms;

  DateFormat get hm;

  DateFormat get ymdText;

  DateFormat get ymdWeekText;

  DateFormat get mdWeekText;

  DateFormat get ymText;

  DateFormat get ymdNum;

  DateFormat get ymdhmsNum;

  DateFormat get ymdhmNum;

  DateFormat get mdHmNum;

  DateFormat get mdNum;

  Weekday get firstDayInWeek;
}

class Lang {
  Lang._();

  static final zhHansFormatter = _ZhHansFormatter();
  static final locale2Format = {
    R.zhHansLocale: _ZhHansFormatter(),
  };

  static RegionalFormatter formatOf(Locale locale) => locale2Format[locale] ?? zhHansFormatter;
}

class _ZhHansFormatter implements RegionalFormatter {
  @override
  final hms = DateFormat("H:mm:ss");
  @override
  final hm = DateFormat("H:mm");
  @override
  final ymdText = DateFormat("yyyy年M月d日", "zh_Hans");
  @override
  final ymdWeekText = DateFormat("yyyy年M月d日 EEEE", "zh_Hans");
  @override
  final mdWeekText = DateFormat("M月d日 EEEE", "zh_Hans");
  @override
  final ymText = DateFormat("yyyy年M月", "zh_Hans");
  @override
  final ymdNum = DateFormat("yyyy/M/d", "zh_Hans");
  @override
  final ymdhmsNum = DateFormat("yyyy/M/d H:mm:ss", "zh_Hans");
  @override
  final ymdhmNum = DateFormat("yyyy/M/d H:mm:ss", "zh_Hans");
  @override
  final mdHmNum = DateFormat("M/d H:mm", "zh_Hans");
  @override
  final mdNum = DateFormat("M/d", "zh_Hans");
  @override
  final firstDayInWeek = Weekday.monday;
}
