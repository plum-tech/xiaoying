import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:mimir/storage/hive/init.dart';
import 'package:mimir/storage/hive/table.dart';
import 'package:mimir/utils/hive.dart';
import 'package:mimir/timetable/entity/timetable.dart';

import '../entity/display.dart';

class _K {
  static const timetable = "/timetable";
  static const lastDisplayMode = "/lastDisplayMode";
}

class TimetableStorage {
  Box get box => HiveInit.timetable;

  final timetable = HiveTable.withUuid<Timetable>(
    base: _K.timetable,
    box: HiveInit.timetable,
    useJson: (
      fromJson: Timetable.fromJson,
      toJson: (timetable) => timetable.toJson(),
    ),
  );

  TimetableStorage();

  DisplayMode? get lastDisplayMode =>
      DisplayMode.at(box.safeGet(_K.lastDisplayMode));

  set lastDisplayMode(DisplayMode? newValue) =>
      box.safePut(_K.lastDisplayMode, newValue?.index);
}
