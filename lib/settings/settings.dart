import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mimir/agreements/settings.dart';
import 'package:mimir/utils/hive.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/school/settings.dart';
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
  late final school = SchoolSettings(box);
  late final theme = _Theme(box);
  late final agreements = AgreementsSettings(box);

  Campus get campus => box.safeGet<Campus>(_K.campus) ?? Campus.fengxian;

  set campus(Campus newV) => box.safePut<Campus>(_K.campus, newV);

  late final $campus = box.providerWithDefault<Campus>(_K.campus, () => Campus.fengxian);

  String? get lastSignature => box.safeGet<String>(_K.lastSignature);

  set lastSignature(String? value) => box.safePut<String>(_K.lastSignature, value);
}

class _ThemeK {
  static const ns = '/theme';
  static const themeColorFromSystem = '$ns/themeColorFromSystem';
  static const themeColor = '$ns/themeColor';
  static const themeMode = '$ns/themeMode';
}

class _Theme {
  final Box box;

  _Theme(this.box);

  // theme
  Color? get themeColor {
    final value = box.safeGet<int>(_ThemeK.themeColor);
    if (value == null) {
      return null;
    } else {
      return Color(value);
    }
  }

  set themeColor(Color? v) {
    box.safePut<int>(_ThemeK.themeColor, v?.toARGB32());
  }

  late final $themeColor = box.provider<Color>(
    _ThemeK.themeColor,
    get: () => themeColor,
    set: (v) => themeColor = v,
  );

  bool get themeColorFromSystem => box.safeGet<bool>(_ThemeK.themeColorFromSystem) ?? true;

  set themeColorFromSystem(bool value) => box.safePut<bool>(_ThemeK.themeColorFromSystem, value);

  late final $themeColorFromSystem = box.provider<bool>(_ThemeK.themeColorFromSystem);

  /// [ThemeMode.system] by default.
  ThemeMode get themeMode => box.safeGet<ThemeMode>(_ThemeK.themeMode) ?? ThemeMode.system;

  set themeMode(ThemeMode value) => box.safePut<ThemeMode>(_ThemeK.themeMode, value);

  late final $themeMode = box.provider<ThemeMode>(_ThemeK.themeMode);
}
