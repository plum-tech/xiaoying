import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:mimir/credentials/entity/credential.dart';
import 'package:mimir/credentials/entity/login_status.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/school/electricity/entity/balance.dart';
import 'package:mimir/school/expense_records/entity/local.dart';
import 'package:mimir/school/exam_result/entity/result.pg.dart';
import 'package:mimir/school/ywb/entity/service.dart';
import 'package:mimir/school/ywb/entity/application.dart';
import 'package:mimir/school/exam_result/entity/result.ug.dart';
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
    // Electric Bill
    hive.addAdapter(ElectricityBalanceAdapter());

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

    // Exam Result
    hive.addAdapter(ExamResultUgAdapter());
    hive.addAdapter(ExamResultItemAdapter());
    hive.addAdapter(UgExamTypeAdapter());
    hive.addAdapter(ExamResultPgAdapter());

    // Expense Records
    hive.addAdapter(TransactionAdapter());
    hive.addAdapter(TransactionTypeAdapter());

    // School
    hive.addAdapter(SemesterAdapter());
    hive.addAdapter(SemesterInfoAdapter());
    hive.addAdapter(CourseCatAdapter());
  }
}
