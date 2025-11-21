import 'storage/announce.dart';

import 'service/announce.dart';

class OaAnnounceInit {
  static late OaAnnounceService service;
  static late OaAnnounceStorage storage;

  static void init() {
    service = const OaAnnounceService();
  }

  static void initStorage() {
    storage = const OaAnnounceStorage();
  }
}
