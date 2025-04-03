import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:mimir/settings/meta.dart';
import 'package:mimir/settings/settings.dart';
import "package:hive/src/hive_impl.dart";
import 'adapter.dart';

class HiveInit {
  const HiveInit._();

  static final core = HiveImpl();
  static final cache = HiveImpl();

  static late Box //
      credentials,
      timetable,
      settings,
      meta,
      cookies;

  static late Box //
      expense,
      class2nd,
      examArrange,
      examResult,
      oaAnnounce,
      ywb,
      electricity,
      schoolCookies;

  static late Map<String, Box> name2Box;
  static late List<Box> cacheBoxes;

  static Future<void> initLocalStorage({
    required Directory coreDir,
    required Directory cacheDir,
  }) async {
    debugPrint("Initializing hive");
    await core.initFlutter(coreDir);
    await cache.initFlutter(cacheDir);
  }

  static void initAdapters() async {
    debugPrint("Initializing hive adapters");
    HiveAdapter.registerCoreAdapters(core);
    HiveAdapter.registerCacheAdapters(cache);
  }

  static Future<void> initBox() async {
    debugPrint("Initializing hive box");
    name2Box = _name2Box([
      credentials = await core.openBox('credentials'),
      settings = await core.openBox('settings'),
      meta = await core.openBox('meta'),
      timetable = await core.openBox('timetable'),
      ...cacheBoxes = [
        if (!kIsWeb) ...[
          cookies = await cache.openBox('cookies'),
          schoolCookies = await cache.openBox('school-cookies'),
          expense = await cache.openBox('expense'),
          examArrange = await cache.openBox('exam-arrange'),
          examResult = await cache.openBox('exam-result'),
          oaAnnounce = await cache.openBox('oa-announce'),
          class2nd = await cache.openBox('class2nd'),
          ywb = await cache.openBox('ywb'),
          electricity = await cache.openBox('electricity'),
        ],
      ],
    ]);
    Settings = SettingsImpl(settings);
    Meta = MetaImpl(meta);
  }

  static Map<String, Box> _name2Box(List<Box> boxes) {
    final map = <String, Box>{};
    for (final box in boxes) {
      map[box.name] = box;
    }
    return map;
  }

  static Future<void> clear() async {
    for (final box in name2Box.values) {
      await box.clear();
    }
  }

  static Future<void> clearCache() async {
    for (final box in cacheBoxes) {
      await box.clear();
    }
  }
}

/// Flutter extensions for Hive.
extension HiveX on HiveInterface {
  /// Initializes Hive with the path from [getApplicationDocumentsDirectory].
  ///
  /// You can provide a [subDir] where the boxes should be stored.
  Future<void> initFlutter(Directory dir) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (kIsWeb) return;
    init(dir.path);
  }

  void addAdapter<T>(TypeAdapter<T> adapter) {
    assert(
      !isAdapterRegistered(adapter.typeId),
      "Trying to register adapter of $T, but the type ID #${adapter.typeId} is occupied by ${(this as dynamic).findAdapterForTypeId(adapter.typeId)}",
    );
    if (!isAdapterRegistered(adapter.typeId)) {
      registerAdapter<T>(adapter);
      debugPrint("Register type adapter of $T at ${adapter.typeId}");
    }
  }
}
