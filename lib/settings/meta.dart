import 'package:mimir/utils/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class _K {
  static const lastLaunchTime = "/lastLaunchTime";
  static const thisLaunchTime = "/thisLaunchTime";
  static const userRealName = "/userRealName";
}

// ignore: non_constant_identifier_names
late MetaImpl Meta;

class MetaImpl {
  final Box box;

  const MetaImpl(this.box);

  DateTime? get lastLaunchTime => box.safeGet<DateTime>(_K.lastLaunchTime);

  set lastLaunchTime(DateTime? newV) => box.safePut<DateTime>(_K.lastLaunchTime, newV);

  DateTime? get thisLaunchTime => box.safeGet<DateTime>(_K.thisLaunchTime);

  set thisLaunchTime(DateTime? newV) => box.safePut<DateTime>(_K.thisLaunchTime, newV);

  String? get userRealName => box.safeGet<String>(_K.userRealName);

  set userRealName(String? newV) => box.safePut<String>(_K.userRealName, newV);
}
