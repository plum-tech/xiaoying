import 'package:hive/hive.dart';
import 'package:mimir/utils/hive.dart';

import 'entity/agreements.dart';

class _AgreementsK {
  static const ns = "/agreements";

  static String acceptanceKeyOf(AgreementType type, AgreementVersion version) =>
      "$ns/acceptance/${type.name}/${version.number}";
}

class AgreementsSettings {
  final Box box;

  AgreementsSettings(this.box);

  bool? getBasicAcceptanceOf(AgreementVersion version) =>
      box.safeGet<bool>(_AgreementsK.acceptanceKeyOf(AgreementType.basic, version));

  Future<void> setBasicAcceptanceOf(AgreementVersion version, bool? newV) async =>
      await box.safePut<bool>(_AgreementsK.acceptanceKeyOf(AgreementType.basic, version), newV);

  late final $basicAcceptanceOf = box.providerFamily<bool, AgreementVersion>(
    (version) => _AgreementsK.acceptanceKeyOf(AgreementType.basic, version),
    get: getBasicAcceptanceOf,
    set: setBasicAcceptanceOf,
  );

  bool? getAccountAcceptanceOf(AgreementVersion version) =>
      box.safeGet<bool>(_AgreementsK.acceptanceKeyOf(AgreementType.account, version));

  Future<void> setAccountAcceptanceOf(AgreementVersion version, bool? newV) async =>
      await box.safePut<bool>(_AgreementsK.acceptanceKeyOf(AgreementType.account, version), newV);

  late final $accountAcceptanceOf = box.providerFamily<bool, AgreementVersion>(
    (version) => _AgreementsK.acceptanceKeyOf(AgreementType.account, version),
    get: getAccountAcceptanceOf,
    set: setAccountAcceptanceOf,
  );
}
