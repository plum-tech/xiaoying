import 'package:flutter/cupertino.dart';
import 'package:hive_ce/hive.dart';
import 'package:mimir/credentials/entity/credential.dart';
import 'package:mimir/credentials/entity/login_status.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/school/ywb/entity/service.dart';
import 'package:mimir/school/ywb/entity/application.dart';
import 'package:mimir/school/oa_announce/entity/announce.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/storage/hive/init.dart';

import 'builtin.dart';

class HiveAdapter {
  HiveAdapter._();

  static void registerCoreAdapters(HiveInterface hive) {
    debugPrint("Register core Hive type");
    // Basic
    hive.addAdapter(SizeAdapter());
    hive.addAdapter(VersionAdapter());
    hive.addAdapter(ThemeModeAdapter());
    hive.addAdapter(CampusAdapter());

    // Credential
    hive.addAdapter(CredentialAdapter());
    hive.addAdapter(OaLoginStatusAdapter());
    hive.addAdapter(OaUserTypeAdapter());
  }

  static void registerCacheAdapters(HiveInterface hive) {
    debugPrint("Register cache Hive type");
    // OA Announcement
    hive.addAdapter(OaAnnounceDetailsAdapter());
    hive.addAdapter(OaAnnounceRecordAdapter());
    hive.addAdapter(OaAnnounceAttachmentAdapter());

    // Application
    hive.addAdapter(YwbServiceDetailSectionAdapter());
    hive.addAdapter(YwbServiceDetailsAdapter());
    hive.addAdapter(YwbServiceAdapter());
    hive.addAdapter(YwbApplicationAdapter());
    hive.addAdapter(YwbApplicationTrackAdapter());

    // School
    hive.addAdapter(SemesterAdapter());
    hive.addAdapter(SemesterInfoAdapter());
    hive.addAdapter(CourseCatAdapter());
  }
}
