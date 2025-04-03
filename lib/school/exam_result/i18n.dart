import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/l10n/common.dart';
import 'package:mimir/school/i18n.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  static const ns = "examResult";
  final gpa = const _Gpa();
  final course = const CourseI18n();

  String get title => "$ns.title".tr();

  String get check => "$ns.check".tr();

  String get score => "$ns.score".tr();

  String get maxScore => "$ns.maxScore".tr();

  String get publishTime => "$ns.publishTime".tr();

  String get teacherEval => "$ns.teacherEval".tr();

  String get teacherEvalTitle => "$ns.teacherEvalTitle".tr();

  String get noResultsTip => "$ns.noResultsTip".tr();

  String get examType => "$ns.examType.title".tr();

  String get courseNotEval => "$ns.courseNotEval".tr();

  String get examRequireEvalTip => "$ns.examRequireEvalTip".tr();
}

class _Gpa {
  const _Gpa();

  static const ns = "${_I18n.ns}.gpa";

  String get title => "$ns.title".tr();

  String lessonSelected(int count) => "$ns.lessonSelected".tr(args: [
        count.toString(),
      ]);

  String credit(double point) => "$ns.credit".tr(args: [
        point.toString(),
      ]);

  String gpaResult(double point) => "$ns.gpaResult".tr(args: [
        point.toStringAsPrecision(2),
      ]);

  String get selectAll => "$ns.selectAll".tr();

  String get invert => "$ns.invert".tr();

  String get exceptGenEd => "$ns.exceptGenEd".tr();

  String get exceptFailed => "$ns.exceptFailed".tr();
}
