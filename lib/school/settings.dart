import 'package:flutter/foundation.dart';
import 'package:mimir/utils/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _kElectricityAutoRefresh = true;
const _kExpenseRecordsAutoRefresh = true;

const _kClass2ndAutoRefresh = true;

class SchoolSettings {
  final Box box;

  SchoolSettings(this.box);

  late final electricity = _Electricity(box);
  late final expense = _ExpenseRecords(box);
  late final class2nd = _Class2nd(box);

  static const ns = "/school";
}

class _Class2ndK {
  static const ns = "${SchoolSettings.ns}/class2nd";
  static const autoRefresh = "$ns/autoRefresh";
}

class _Class2nd {
  final Box box;

  const _Class2nd(this.box);

  bool get autoRefresh => box.safeGet<bool>(_Class2ndK.autoRefresh) ?? _kClass2ndAutoRefresh;

  set autoRefresh(bool newV) => box.safePut<bool>(_Class2ndK.autoRefresh, newV);
}

class _ElectricityK {
  static const ns = "${SchoolSettings.ns}/electricity";
  static const autoRefresh = "$ns/autoRefresh";
  static const selectedRoom = "$ns/selectedRoom";
}

class _Electricity {
  final Box box;

  _Electricity(this.box);

  bool get autoRefresh => box.safeGet<bool>(_ElectricityK.autoRefresh) ?? _kElectricityAutoRefresh;

  set autoRefresh(bool foo) => box.safePut<bool>(_ElectricityK.autoRefresh, foo);

  String? get selectedRoom => box.safeGet<String>(_ElectricityK.selectedRoom);

  late final $selectedRoom = box.provider<String>(_ElectricityK.selectedRoom);

  set selectedRoom(String? newV) => box.safePut<String>(_ElectricityK.selectedRoom, newV);

  ValueListenable listenSelectedRoom() => box.listenable(keys: [_ElectricityK.selectedRoom]);
}

class _ExpenseK {
  static const ns = "${SchoolSettings.ns}/expenseRecords";
  static const autoRefresh = "$ns/autoRefresh";
}

class _ExpenseRecords {
  final Box box;

  const _ExpenseRecords(this.box);

  bool get autoRefresh => box.safeGet<bool>(_ExpenseK.autoRefresh) ?? _kExpenseRecordsAutoRefresh;

  set autoRefresh(bool foo) => box.safePut<bool>(_ExpenseK.autoRefresh, foo);
}
