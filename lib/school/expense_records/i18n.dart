import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/l10n/common.dart';

import 'entity/local.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  static const ns = "expenseRecords";
  final unit = const UnitI18n();
  final stats = const _Stats();
  final view = const _View();

  String get title => "$ns.title".tr();

  String get noTransactionsTip => "$ns.noTransactionsTip".tr();

  String get refreshSuccessTip => "$ns.refreshSuccessTip".tr();

  String get refreshFailedTip => "$ns.refreshFailedTip".tr();

  String get list => "$ns.list".tr();

  String get statistics => "$ns.statistics".tr();

  String get topUp => "$ns.topUp".tr();

  String get launchFailed => "$ns.launchFailed".tr();

  String get launchFailedDesc => "$ns.launchFailedDesc".tr();

  String balanceInCard(String amount) => "$ns.balanceInCard".tr(args: [amount]);

  String lastTransaction(String amount, String place) => "$ns.lastTransaction".tr(namedArgs: {
        "amount": amount,
        "place": place,
      });

  String income(String amount) => "$ns.income".tr(args: [amount]);

  String outcome(String amount) => "$ns.outcome".tr(args: [amount]);

  String lastUpdateTime(String time) => "$ns.lastUpdateTime".tr(args: [time]);
}

class _Stats {
  const _Stats();

  static const ns = "${_I18n.ns}.stats";

  String get title => "$ns.title".tr();

  String get total => "$ns.total".tr();

  String get summary => "$ns.summary".tr();

  String get details => "$ns.details".tr();

  String averageSpendIn({
    required String amount,
    required TransactionType type,
  }) =>
      "$ns.averageSpendIn".tr(namedArgs: {
        "amount": amount,
        "type": type.l10n(),
      });

  String maxSpendOf({
    required String amount,
  }) =>
      "$ns.maxSpendOf".tr(namedArgs: {
        "amount": amount,
      });

  String get averageLineLabel => "$ns.averageLineLabel".tr();

  String get hourlyAverage => "$ns.hourlyAverage".tr();

  String get dailyAverage => "$ns.dailyAverage".tr();

  String get monthlyAverage => "$ns.monthlyAverage".tr();

  String get today => "$ns.today".tr();

  String get yesterday => "$ns.yesterday".tr();

  String get thisWeek => "$ns.thisWeek".tr();

  String get lastWeek => "$ns.lastWeek".tr();

  String get thisMonth => "$ns.thisMonth".tr();

  String get lastMonth => "$ns.lastMonth".tr();

  String get thisYear => "$ns.thisYear".tr();

  String get lastYear => "$ns.lastYear".tr();
}

class _View {
  const _View();

  static const ns = "${_I18n.ns}.view";

  String get balance => "$ns.balance".tr();

  String get rmb => "$ns.rmb".tr();
}
