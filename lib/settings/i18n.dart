import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/credentials/i18n.dart';
import 'package:mimir/l10n/app.dart';
import 'package:mimir/l10n/common.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  final oa = const OaCredentialsI18n();
  final eduEmail = const EmailCredentialsI18n();
  final dev = const _DevOptions();
  final about = const _About();
  final app = const AppI18n();

  static const ns = "settings";

  String get title => "$ns.title".tr();

  String get language => "$ns.language".tr();

  String get themeColor => "$ns.themeColor".tr();

  String get fromSystem => "$ns.fromSystem".tr();

  String get themeModeTitle => "$ns.themeMode.title".tr();

  String get clearCacheTitle => "$ns.clearCache.title".tr();

  String get clearCacheDesc => "$ns.clearCache.desc".tr();

  String get clearCacheRequest => "$ns.clearCache.request".tr();

  String get wipeDataTitle => "$ns.wipeData.title".tr();

  String get wipeDataDesc => "$ns.wipeData.desc".tr();

  String get wipeDataRequest => "$ns.wipeData.request".tr();

  String get wipeDataRequestDesc => "$ns.wipeData.requestDesc".tr();

  String get loginTest => "$ns.loginTest.title".tr();

  String get loginTestDesc => "$ns.loginTest.desc".tr();
}

class _About {
  const _About();

  static const ns = "${_I18n.ns}.about";

  String get title => "$ns.title".tr();

  String get version => "$ns.version".tr();

  String get icpLicense => "$ns.icpLicense".tr();

  String get termsOfService => "$ns.termsOfService".tr();

  String get privacyPolicy => "$ns.privacyPolicy".tr();

  String get marketingWebsite => "$ns.marketingWebsite".tr();
}

class _DevOptions {
  const _DevOptions();

  final storage = const _Storage();

  static const ns = "${_I18n.ns}.dev";

  String get title => "$ns.title".tr();

  String get devMode => "$ns.devMode.title".tr();

  String get demoMode => "$ns.demoMode.title".tr();

  String get devModeActivateTip => "$ns.activateTip".tr();

  String get reload => "$ns.reload.title".tr();

  String get reloadDesc => "$ns.reload.desc".tr();

  String get localStorage => "$ns.localStorage.title".tr();

  String get localStorageDesc => "$ns.localStorage.desc".tr();
}

class _Storage with CommonI18nMixin {
  const _Storage();

  static const ns = "${_DevOptions.ns}.localStorage";

  String get title => "$ns.title".tr();

  String get selectBoxTip => "$ns.selectBoxTip".tr();

  String get clearBoxDesc => "$ns.clearBoxDesc".tr();

  String get deleteItemDesc => "$ns.deleteItemDesc".tr();

  String get emptyValueDesc => "$ns.emptyValueDesc".tr();
}
