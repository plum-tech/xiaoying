import 'package:flutter/cupertino.dart';
import 'package:hive_ce/hive.dart';
import 'package:mimir/entity/campus.dart';
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
  }

  static void registerCacheAdapters(HiveInterface hive) {
    debugPrint("Register cache Hive type");
    hive.addAdapter(SemesterAdapter());
    hive.addAdapter(SemesterInfoAdapter());
    hive.addAdapter(CourseCatAdapter());
  }
}
