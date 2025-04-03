import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:mimir/init.dart';

import 'package:mimir/session/sso.dart';
import 'package:mimir/utils/error.dart';

class AuthServerService {
  SsoSession get _session => Init.ssoSession;

  const AuthServerService();

  Future<String?> getPersonName() async {
    try {
      final response = await _session.request('https://authserver.sit.edu.cn/authserver/index.do');
      final html = BeautifulSoup(response.data);
      final resultDesktop = html.find('div', class_: 'auth_username')?.text ?? '';
      final resultMobile = html.find('div', class_: 'index-nav-name')?.text ?? '';

      final result = (resultMobile + resultDesktop).trim();
      return result.isNotEmpty ? result : null;
    } catch (error, stackTrace) {
      debugPrintError(error, stackTrace);
      return null;
    }
  }
}
