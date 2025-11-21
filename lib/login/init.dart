import 'service/authserver.dart';

class LoginInit {
  static late AuthServerService authServerService;

  static void init() {
    authServerService = const AuthServerService();
  }

  static void initStorage() {}
}
