import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/l10n/common.dart';
import 'package:mimir/school/i18n.dart';

import 'entity/issue.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  static const ns = "timetable";
  final time = const TimeI18n();
  final mine = const _Mine();
  final p13n = const _P13n();
  final import = const _Import();
  final export = const _Export();
  final course = const CourseI18n();
  final editor = const _Editor();
  final issue = const _Issue();
  final freeTip = const _FreeTip();
  final campus = const CampusI10n();
  final settings = const _Settings();

  String get navigation => "$ns.navigation".tr();

  String weekOrderedName({required int number}) => "$ns.weekOrderedName".tr(args: [number.toString()]);

  String get startWith => "$ns.startWith".tr();

  String get createdWhen => "$ns.createdWhen".tr();

  String get jump => "$ns.jump".tr();

  String get findToday => "$ns.findToday".tr();

  String get signature => "$ns.signature".tr();

  String get signaturePlaceholder => "$ns.signaturePlaceholder".tr();

  String get lunchtime => "$ns.lunchtime".tr();

  String get dinnertime => "$ns.dinnertime".tr();
}

class _Mine {
  const _Mine();

  static const ns = "${_I18n.ns}.mine";

  String get title => "$ns.title".tr();

  String get exportFile => "$ns.exportFile".tr();

  String get exportCalendar => "$ns.exportCalendar".tr();

  String get patch => "$ns.patch".tr();

  String get deleteRequest => "$ns.deleteRequest".tr();

  String get deleteRequestDesc => "$ns.deleteRequestDesc".tr();

  String get emptyTip => "$ns.emptyTip".tr();

  String get details => "$ns.details".tr();
}

class _P13n {
  const _P13n();

  static const ns = "${_I18n.ns}.p13n";
  final cell = const _CellStyle();

  String get title => "$ns.title".tr();
}

class _CellStyle {
  const _CellStyle();

  static const ns = "${_P13n.ns}.cellStyle";

  String get title => "$ns.title".tr();

  String get showTeachers => "$ns.showTeachers.title".tr();

  String get showTeachersDesc => "$ns.showTeachers.desc".tr();

  String get grayOut => "$ns.grayOut.title".tr();

  String get grayOutDesc => "$ns.grayOut.desc".tr();

  String get harmonize => "$ns.harmonize.title".tr();

  String get harmonizeDesc => "$ns.harmonize.desc".tr();

  String get alpha => "$ns.alpha".tr();
}

class _Import {
  const _Import();

  static const ns = "${_I18n.ns}.import";

  String get title => "$ns.title".tr();

  String get import => "$ns.import".tr();

  String get fromFile => "$ns.fromFile".tr();

  String get fromFileBtn => "$ns.fromFileBtn".tr();

  String get connectivityCheckerDesc => "$ns.connectivityCheckerDesc".tr();

  String get selectSemesterTip => "$ns.selectSemesterTip".tr();

  String get endTip => "$ns.endTip".tr();

  String get failed => "$ns.failed".tr();

  String get failedDesc => "$ns.failedDesc".tr();

  String get networkFailedDesc => "$ns.networkFailedDesc".tr();

  String get failedTip => "$ns.failedTip".tr();

  String get tryImportBtn => "$ns.tryImportBtn".tr();

  String get importing => "$ns.importing".tr();

  String get timetableInfo => "$ns.timetableInfo".tr();

  String defaultName(
    String semester,
    String yearStart,
    String yearEnd,
  ) =>
      "$ns.defaultName".tr(namedArgs: {
        "semester": semester,
        "yearStart": yearStart,
        "yearEnd": yearEnd,
      });

  String get fileSystemError => "$ns.fileSystemError.title".tr();

  String get formatError => "$ns.formatError.title".tr();

  String get formatErrorDesc => "$ns.formatError.desc".tr();

  String get alreadyLatest => "$ns.alreadyLatest.title".tr();

  String get alreadyLatestDesc => "$ns.alreadyLatest.desc".tr();

  String get updateAvailable => "$ns.updateAvailable.title".tr();

  String get updateAvailableDesc => "$ns.updateAvailable.desc".tr();
}

class _Editor {
  const _Editor();

  static const ns = "${_I18n.ns}.edit";

  String get name => "$ns.name".tr();

  String get infoTab => "$ns.tab.info".tr();

  String get advancedTab => "$ns.tab.advanced".tr();

  String get editCourse => "$ns.editCourse".tr();

  String get newCourse => "$ns.newCourse".tr();

  String get addCourse => "$ns.addCourse".tr();

  String get repeating => "$ns.repeating".tr();

  String get daysOfWeek => "$ns.daysOfWeek".tr();

  String timeslotsSpanMultiple({
    required String from,
    required String to,
  }) =>
      "$ns.timeslots.multiple".tr(namedArgs: {
        "from": from,
        "to": to,
      });

  String timeslotsSpanSingle(String at) => "$ns.timeslots.single".tr(args: [at]);
}

class _Issue {
  const _Issue();

  static const ns = "${_I18n.ns}.issue";

  String get title => "$ns.title".tr();

  String get resolve => "$ns.resolve".tr();
}

extension TimetableIssueTypeI18nX on TimetableIssueType {
  String l10n() => "${_Issue.ns}.builtin.$name.title".tr();

  String l10nDesc() => "${_Issue.ns}.builtin.$name.desc".tr();
}

class _Export {
  const _Export();

  static const ns = "${_I18n.ns}.export";

  String get title => "$ns.title".tr();

  String get export => "$ns.export".tr();

  String get iOSGetShortcutAction => "$ns.iOSGetShortcutAction".tr();

  String get lessonMode => "$ns.lessonMode.title".tr();

  String get lessonModeMerged => "$ns.lessonMode.merged".tr();

  String get lessonModeMergedTip => "$ns.lessonMode.mergedTip".tr();

  String get lessonModeSeparate => "$ns.lessonMode.separate".tr();

  String get lessonModeSeparateTip => "$ns.lessonMode.separateTip".tr();

  String get enableAlarm => "$ns.enableAlarm.title".tr();

  String get enableAlarmDesc => "$ns.enableAlarm.desc".tr();

  String get alarmMode => "$ns.alarmMode.title".tr();

  String get alarmModeSound => "$ns.alarmMode.sound".tr();

  String get alarmModeDisplay => "$ns.alarmMode.display".tr();

  String get alarmDuration => "$ns.alarmDuration".tr();

  String get alarmBeforeClassBegins => "$ns.alarmBeforeClassBegins.title".tr();

  String alarmBeforeClassBeginsDesc(Duration duration) => "$ns.alarmBeforeClassBegins.desc".tr(namedArgs: {
        "duration": i18n.time.minuteFormat(duration.inMinutes.toString()),
      });
}

class _FreeTip {
  const _FreeTip();

  static const ns = "${_I18n.ns}.freeTip";

  String get dayTip => "$ns.dayTip".tr();

  String get isTodayTip => "$ns.isTodayTip".tr();

  String get weekTip => "$ns.weekTip".tr();

  String get isThisWeekTip => "$ns.isThisWeekTip".tr();

  String get termTip => "$ns.termTip".tr();

  String get findNearestWeekWithClass => "$ns.findNearestWeekWithClass".tr();

  String get findNearestDayWithClass => "$ns.findNearestDayWithClass".tr();
}

class _Settings {
  const _Settings();

  static const ns = "${_I18n.ns}.settings";

  String get autoUseImported => "$ns.autoUseImported.title".tr();

  String get autoUseImportedDesc => "$ns.autoUseImported.desc".tr();

  String get showTimetableNavigation => "$ns.showTimetableNavigation.title".tr();

  String get showTimetableNavigationDesc => "$ns.showTimetableNavigation.desc".tr();

  String get palette => "$ns.palette.title".tr();

  String get paletteDesc => "$ns.palette.desc".tr();

  String get cellStyle => "$ns.cellStyle.title".tr();

  String get cellStyleDesc => "$ns.cellStyle.desc".tr();

  String get quickLookLessonOnTap => "$ns.quickLookLessonOnTap.title".tr();

  String get quickLookLessonOnTapDesc => "$ns.quickLookLessonOnTap.desc".tr();

  String get autoSyncTimetable => "$ns.autoSyncTimetable.title".tr();

  String get autoSyncTimetableDesc => "$ns.autoSyncTimetable.desc".tr();
}
