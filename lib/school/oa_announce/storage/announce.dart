import 'package:mimir/utils/hive.dart';
import 'package:hive/hive.dart';
import 'package:mimir/storage/hive/init.dart';

import '../entity/announce.dart';

class _K {
  static String announce(String uuid) => '/announce/$uuid';

  static String announceDetails(String uuid) => '/announceDetails/$uuid';

  static String announceIdList(OaAnnounceCat type) => '/announceIdList/$type';
}

class OaAnnounceStorage {
  Box get box => HiveInit.oaAnnounce;

  const OaAnnounceStorage();

  List<String>? getAnnounceIdList(OaAnnounceCat type) => box.safeGet<List<String>>(_K.announceIdList(type));

  Future<void> setAnnounceIdList(OaAnnounceCat type, List<String>? announceIdList) =>
      box.safePut<List<String>>(_K.announceIdList(type), announceIdList);

  OaAnnounceRecord? getAnnounce(String uuid) => box.safeGet<OaAnnounceRecord>(_K.announce(uuid));

  Future<void> setAnnounce(String uuid, OaAnnounceRecord? announce) =>
      box.safePut<OaAnnounceRecord>(_K.announce(uuid), announce);

  OaAnnounceDetails? getAnnounceDetails(String uuid) => box.safeGet<OaAnnounceDetails>(_K.announceDetails(uuid));

  Future<void> setAnnounceDetails(String uuid, OaAnnounceDetails? details) =>
      box.safePut<OaAnnounceDetails>(_K.announceDetails(uuid), details);

  List<OaAnnounceRecord>? getAnnouncements(OaAnnounceCat type) {
    final idList = getAnnounceIdList(type);
    if (idList == null) return null;
    final res = <OaAnnounceRecord>[];
    for (final id in idList) {
      final announce = getAnnounce(id);
      if (announce != null) {
        res.add(announce);
      }
    }
    return res;
  }

  Future<void>? setAnnouncements(OaAnnounceCat type, List<OaAnnounceRecord>? announcements) async {
    if (announcements == null) {
      await setAnnouncements(type, null);
    } else {
      await setAnnounceIdList(type, announcements.map((e) => e.uuid).toList(growable: false));
      for (final announce in announcements) {
        await setAnnounce(announce.uuid, announce);
      }
    }
  }
}
