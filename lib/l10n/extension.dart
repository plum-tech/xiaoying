import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mimir/l10n/time.dart';

import 'lang.dart';

export 'package:mimir/r.dart';

export 'lang.dart';

extension I18nBuildContext on BuildContext {
  ///e.g.: Wednesday, September 21, 2022
  String formatYmdWeekText(DateTime date) => Lang.formatOf(locale).ymdWeekText.format(date);

  ///e.g.: Wednesday, September 21
  String formatMdWeekText(DateTime date) => Lang.formatOf(locale).mdWeekText.format(date);

  ///e.g.: September 21, 2022
  String formatYmdText(DateTime date) => Lang.formatOf(locale).ymdText.format(date);

  ///e.g.: 9/21/2022
  String formatYmdNum(DateTime date) => Lang.formatOf(locale).ymdNum.format(date);

  ///e.g.: 9/21/2022 23:57:23
  String formatYmdhmsNum(DateTime date) => Lang.formatOf(locale).ymdhmsNum.format(date);

  ///e.g.: 9/21/2022 23:57
  String formatYmdhmNum(DateTime date) => Lang.formatOf(locale).ymdhmNum.format(date);

  String formatYmText(DateTime date) => Lang.formatOf(locale).ymText.format(date);

  /// e.g.: 8:32:59
  String formatHmsNum(DateTime date) => Lang.formatOf(locale).hms.format(date);

  /// e.g.: 8:32
  String formatHmNum(DateTime date) => Lang.formatOf(locale).hm.format(date);

  /// e.g.: 9/21
  String formatMdNum(DateTime date) => Lang.formatOf(locale).mdNum.format(date);

  /// e.g.: 9/21 7:32
  String formatMdhmNum(DateTime date) => Lang.formatOf(locale).mdHmNum.format(date);

  Weekday firstDayInWeek() => Lang.formatOf(locale).firstDayInWeek;
}

extension BrightnessL10nX on Brightness {
  String l10n() => "brightness.$name".tr();
}

extension ThemeModeL10nX on ThemeMode {
  String l10n() => "themeMode.$name".tr();
}
