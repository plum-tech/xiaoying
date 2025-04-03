import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/l10n/common.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  static const ns = "school";
  final course = const CourseI18n();
  final settings = const _Settings();

  String get title => "$ns.title".tr();

  String get navigation => "$ns.navigation".tr();
}

class CourseI18n {
  const CourseI18n();

  static const ns = "${_I18n.ns}.course";

  String get courseName => "$ns.courseName".tr();

  String get classCode => "$ns.classCode".tr();

  String get courseCode => "$ns.courseCode".tr();

  String get place => "$ns.place".tr();

  String get campus => "$ns.campus".tr();

  String get displayable => "$ns.displayable".tr();

  String teacher(int count) => "$ns.teacher".plural(count);

  String get credit => "$ns.credit".tr();

  String get schoolYear => "$ns.schoolYear".tr();

  String get semester => "$ns.semester".tr();

  String get category => "$ns.category".tr();

  String get compulsory => "$ns.compulsory".tr();

  String get elective => "$ns.elective".tr();
}

class _Settings {
  const _Settings();

  static const ns = "${_I18n.ns}.settings";
  final class2nd = const _Class2nd();
  final examResult = const _ExamResult();
  final electricity = const _Electricity();
  final expense = const _Expense();
}

class _Class2nd {
  static const ns = "${_Settings.ns}.class2nd";

  const _Class2nd();

  String get autoRefresh => "$ns.autoRefresh.title".tr();

  String get autoRefreshDesc => "$ns.autoRefresh.desc".tr();
}

class _ExamResult {
  static const ns = "${_Settings.ns}.examResult";

  const _ExamResult();

  String get showResultPreview => "$ns.showResultPreview.title".tr();

  String get showResultPreviewDesc => "$ns.showResultPreview.desc".tr();
}

class _Electricity {
  static const ns = "${_Settings.ns}.electricity";

  const _Electricity();

  String get autoRefresh => "$ns.autoRefresh.title".tr();

  String get autoRefreshDesc => "$ns.autoRefresh.desc".tr();
}

class _Expense {
  static const ns = "${_Settings.ns}.expenseRecords";

  const _Expense();

  String get autoRefresh => "$ns.autoRefresh.title".tr();

  String get autoRefreshDesc => "$ns.autoRefresh.desc".tr();
}
