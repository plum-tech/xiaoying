import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/l10n/common.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  static const ns = "oaAnnounce";
  final info = const _Info();

  String get title => "$ns.title".tr();

  String get noOaAnnouncementsTip => "$ns.noOaAnnouncementsTip".tr();

  String get downloadCompleted => "$ns.downloadCompleted".tr();

  String get downloadFailed => "$ns.downloadFailed".tr();

  String get downloading => "$ns.downloading".tr();
}

class _Info {
  const _Info();

  static const ns = "${_I18n.ns}.info";

  String attachmentHeader(int count) => "$ns.attachmentHeader".plural(count);

  String get title => "$ns.title".tr();

  String get publishTime => "$ns.publishTime".tr();

  String get department => "$ns.department".tr();

  String get author => "$ns.author".tr();

  String get tags => "$ns.tags".tr();
}
