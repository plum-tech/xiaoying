import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/l10n/common.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  static const ns = "electricity";
  final unit = const UnitI18n();

  String get title => "$ns.title".tr();

  String get searchRoom => "$ns.searchRoom".tr();

  String get balance => "$ns.balance".tr();

  String get remainingPower => "$ns.remainingPower".tr();

  String get searchInvalidTip => "$ns.searchInvalidTip".tr();

  String get refreshSuccessTip => "$ns.refreshSuccessTip".tr();

  String get refreshFailedTip => "$ns.refreshFailedTip".tr();

  String get emptyHistoryTip => "$ns.emptyHistoryTip".tr();

  String get noMatchedRoomNumbers => "$ns.noMatchedRoomNumbers".tr();

  String lastUpdateTime(String time) => "$ns.lastUpdateTime".tr(args: [time]);
}
