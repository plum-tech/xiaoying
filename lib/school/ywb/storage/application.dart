import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mimir/utils/hive.dart';
import 'package:mimir/storage/hive/init.dart';

import '../entity/application.dart';

class _K {
  static const ns = "/application";

  static String applicationListOf(YwbApplicationType type) => "$ns/$type";
}

class YwbApplicationStorage {
  Box get box => HiveInit.ywb;

  YwbApplicationStorage();

  List<YwbApplication>? getApplicationListOf(YwbApplicationType type) =>
      box.safeGet<List>(_K.applicationListOf(type))?.cast<YwbApplication>();

  Future<void> setApplicationListOf(YwbApplicationType type, List<YwbApplication>? newV) =>
      box.safePut<List>(_K.applicationListOf(type), newV);

  Listenable listenApplicationListOf(YwbApplicationType type) => box.listenable(keys: [_K.applicationListOf(type)]);

  late final $applicationOf = box.providerFamily<List<YwbApplication>, YwbApplicationType>(
    _K.applicationListOf,
    get: getApplicationListOf,
    set: setApplicationListOf,
  );
}
