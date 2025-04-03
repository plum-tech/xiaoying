import 'package:hive_flutter/hive_flutter.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/storage/hive/init.dart';
import 'package:mimir/utils/hive.dart';

import '../entity/credential.dart';
import '../entity/login_status.dart';

class CredentialStorage {
  Box get box => HiveInit.credentials;

  CredentialStorage();

  late final oa = _Oa(box);
}

class _OaK {
  static const ns = "/oa";
  static const credentials = "$ns/credentials";
  static const lastAuthTime = "$ns/lastAuthTime";
  static const loginStatus = "$ns/loginStatus";
  static const userType = "$ns/userType";
}

class _Oa {
  final Box box;

  _Oa(this.box);

  Credential? get credentials => box.safeGet<Credential>(_OaK.credentials);

  set credentials(Credential? newV) => box.safePut<Credential>(_OaK.credentials, newV);

  late final $credentials = box.provider<Credential>(_OaK.credentials);

  DateTime? get lastAuthTime => box.safeGet<DateTime>(_OaK.lastAuthTime);

  set lastAuthTime(DateTime? newV) => box.safePut<DateTime>(_OaK.lastAuthTime, newV);

  late final $lastAuthTime = box.provider<DateTime>(_OaK.lastAuthTime);

  OaLoginStatus? get loginStatus => box.safeGet<OaLoginStatus>(_OaK.loginStatus) ?? OaLoginStatus.never;

  set loginStatus(OaLoginStatus? newV) => box.safePut<OaLoginStatus>(_OaK.loginStatus, newV);

  late final $loginStatus = box.providerWithDefault<OaLoginStatus>(_OaK.loginStatus, () => OaLoginStatus.never);

  OaUserType get userType => box.safeGet<OaUserType>(_OaK.userType) ?? OaUserType.none;

  set userType(OaUserType newV) => box.safePut<OaUserType>(_OaK.userType, newV);

  late final $userType = box.providerWithDefault<OaUserType>(_OaK.userType, () => OaUserType.none);
}
