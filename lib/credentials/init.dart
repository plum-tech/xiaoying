import 'storage/credential.dart';

class CredentialsInit {
  static late CredentialStorage storage;

  static void init() {}

  static void initStorage() {
    storage = CredentialStorage();
  }
}
