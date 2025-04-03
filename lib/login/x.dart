import 'package:mimir/credentials/entity/credential.dart';
import 'package:mimir/credentials/entity/login_status.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/credentials/utils.dart';
import 'package:mimir/init.dart';
import 'package:mimir/settings/meta.dart';
import 'package:mimir/settings/settings.dart';

import 'init.dart';

class XLogin {
  static Future<void> login(Credential credentials) async {
    credentials = credentials.copyWith(
      account: credentials.account.toUpperCase(),
    );
    final userType = estimateOaUserType(credentials.account);
    await Init.ssoSession.deleteSitUriCookies();
    await Init.ssoSession.loginLocked(credentials, active: true);
    // set user's real name to signature by default.
    final personName = await LoginInit.authServerService.getPersonName();
    Meta.userRealName ??= personName;
    Settings.lastSignature ??= personName;
    CredentialsInit.storage.oa.credentials = credentials;
    CredentialsInit.storage.oa.loginStatus = OaLoginStatus.validated;
    CredentialsInit.storage.oa.lastAuthTime = DateTime.now();
    CredentialsInit.storage.oa.userType = userType ?? OaUserType.none;
  }
}
