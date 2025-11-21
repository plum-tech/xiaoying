import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/credentials/i18n.dart';
import 'package:mimir/l10n/common.dart';

class CommonAuthI18n with CommonAuthI18nMixin, CommonI18nMixin {
  const CommonAuthI18n();
}

mixin class CommonAuthI18nMixin {
  static const ns = "auth";

  String get signIn => "$ns.signIn".tr();

  String get signUp => "$ns.signUp".tr();

  String get signOut => "$ns.signOut".tr();

  String get login => "$ns.login".tr();

  String get forgotPwd => "$ns.forgotPwd".tr();

  String get formatError => "$ns.formatError".tr();

  String get validateInputAccountPwdRequest => "$ns.validateInputAccountPwdRequest".tr();

  String get invalidAccountFormat => "$ns.invalidAccountFormat".tr();

  String get offlineModeBtn => "$ns.offlineModeBtn".tr();

  String get failedWarn => "$ns.failedWarn".tr();

  String get unknownAuthErrorTip => "$ns.unknownAuthErrorTip".tr();
}

class OaLoginI18n extends CommonAuthI18n {
  const OaLoginI18n();

  static const ns = "oa.login";

  final credentials = const OaCredentialsI18n();

  String get welcomeHeader => "$ns.welcomeHeader".tr();

  String get loginOa => "$ns.loginOa".tr();

  String get accountHint => "$ns.accountHint".tr();

  String get oaPwdHint => "$ns.oaPwdHint".tr();

  String get freshmanSystemPwd => "$ns.freshmanSystemPwd".tr();

  String get freshmanSystemPwdHint => "$ns.freshmanSystemPwdHint".tr();

  String get schoolServerUnconnectedTip => "$ns.schoolServerUnconnectedTip".tr();

  String get loginRequired => "$ns.loginRequired".tr();

  String get neverLoggedInTip => "$ns.neverLoggedInTip".tr();

  String get disclaimer => "$ns.disclaimer".tr();

  String get freshmanTip => "$ns.freshmanTip".tr();

  String get freshmanSystemTip => "$ns.freshmanSystemTip".tr();
}
