import 'package:easy_localization/easy_localization.dart';

mixin class CommonI18nMixin {
  String get open => "open".tr();

  String get delete => "delete".tr();

  String get confirm => "confirm".tr();

  String get error => "error".tr();

  String get ok => "ok".tr();

  String get yes => "yes".tr();

  String get refresh => "refresh".tr();

  String get update => "update".tr();

  String get sync => "sync".tr();

  String get close => "close".tr();

  String get submit => "submit".tr();

  String get cancel => "cancel".tr();

  String get back => "back".tr();

  String get clear => "clear".tr();

  String get save => "save".tr();

  String get continue$ => "continue".tr();

  String get unknown => "unknown".tr();

  String get failed => "failed".tr();

  String get download => "download".tr();

  String get fetching => "fetching".tr();

  String get warning => "warning".tr();

  String get exceptionInfo => "exceptionInfo".tr();

  String get untitled => "untitled".tr();

  String get congratulations => "congratulations".tr();

  String get search => "search".tr();

  String get seeAll => "seeAll".tr();

  String get select => "select".tr();

  String get unselect => "unselect".tr();

  String get share => "share".tr();

  String get edit => "edit".tr();

  String get use => "use".tr();

  String get used => "used".tr();

  String get preview => "preview".tr();

  String get copy => "copy".tr();

  String get upload => "upload".tr();

  String get pick => "pick".tr();

  String get retry => "retry".tr();

  String get duplicate => "duplicate".tr();

  String copyTipOf(String item) => "copyTip".tr(args: [item]);

  String get done => "done".tr();

  String get openInBrowser => "openInBrowser".tr();

  String get choose => "choose".tr();

  String get unspecified => "unspecified".tr();

  String get add => "add".tr();

  String get rename => "rename".tr();

  String get enter => "enter".tr();

  String get create => "create".tr();

  String get troubleshoot => "troubleshoot".tr();
}

class CommonI18n with CommonI18nMixin {
  const CommonI18n();
}

class UnitI18n {
  const UnitI18n();

  static const ns = "unit";

  String rmb(String amount) => "$ns.rmb".tr(args: [amount]);

  String powerKwh(String amount) => "$ns.powerKwh".tr(args: [amount]);
}

class TimeI18n {
  const TimeI18n();

  static const ns = "time";

  String get minute => "$ns.minute".tr();

  String get hour => "$ns.hour".tr();

  String hourMinuteFormat(String hour, String minute) => "$ns.hourMinuteFormat".tr(namedArgs: {
        "hour": hour,
        "minute": minute,
      });

  String hourFormat(String hour) => "$ns.hourFormat".tr(args: [hour]);

  String minuteFormat(String minute) => "$ns.minuteFormat".tr(args: [minute]);
}

class CampusI10n {
  const CampusI10n();

  static const ns = "campus";

  String get xuhui => "$ns.xuhui".tr();

  String get fengxian => "$ns.fengxian".tr();
}
