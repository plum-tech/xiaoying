import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/l10n/common.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  static const ns = "agreements";

  const _I18n();

  String get acceptanceRequired => "$ns.acceptanceRequired.title".tr();

  String get acceptanceRequiredDesc => "$ns.acceptanceRequired.desc".tr();

  String get privacyPolicy => "$ns.privacyPolicy.title".tr();

  String get privacyPolicyContent => "$ns.privacyPolicy.content".tr();

  String get accept => "$ns.privacyPolicy.accept".tr();

  String get decline => "$ns.privacyPolicy.decline".tr();

  String get onDecline => "$ns.privacyPolicy.onDecline".tr();
}
