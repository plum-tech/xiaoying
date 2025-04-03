import 'package:easy_localization/easy_localization.dart';

enum AgreementType {
  basic,
  account;

  String l10n() => "agreements.basic".tr();
}

enum AgreementVersion {
  v20240915("20240915"),
  v20241118("20241118"),
  ;

  static const current = v20241118;

  final String number;

  const AgreementVersion(this.number);
}
