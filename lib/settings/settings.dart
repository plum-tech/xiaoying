import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:mimir/agreements/settings.dart';
import 'package:mimir/utils/hive.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/timetable/settings.dart';

class _K {
  static const ns = "/settings";
  static const campus = '$ns/campus';

  // static const focusTimetable = '$ns/focusTimetable';
  static const lastSignature = '$ns/lastSignature';
}

// ignore: non_constant_identifier_names
late SettingsImpl Settings;

class SettingsImpl {
  final Box box;

  SettingsImpl(this.box);

  late final timetable = TimetableSettings(box);
  late final agreements = AgreementsSettings(box);

  Campus get campus => box.safeGet<Campus>(_K.campus) ?? Campus.fengxian;

  set campus(Campus newV) => box.safePut<Campus>(_K.campus, newV);

  late final $campus = box.providerWithDefault<Campus>(_K.campus, () => Campus.fengxian);

  String? get lastSignature => box.safeGet<String>(_K.lastSignature);

  set lastSignature(String? value) => box.safePut<String>(_K.lastSignature, value);
}
