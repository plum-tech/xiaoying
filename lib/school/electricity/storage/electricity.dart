import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mimir/utils/hive.dart';
import 'package:mimir/storage/hive/init.dart';

import '../entity/balance.dart';

class _K {
  static const lastBalance = "/lastBalance";
  static const searchHistory = "/searchHistory";
  static const lastUpdateTime = "/lastUpdateTime";
}

class ElectricityStorage {
  Box get box => HiveInit.electricity;
  final int maxHistoryLength;

  ElectricityStorage({
    this.maxHistoryLength = 20,
  });

  ValueListenable listenBalance() => box.listenable(keys: [_K.lastBalance]);

  late final $lastBalance = box.provider<ElectricityBalance>(_K.lastBalance);

  ElectricityBalance? get lastBalance => box.safeGet<ElectricityBalance>(_K.lastBalance);

  set lastBalance(ElectricityBalance? newV) => box.safePut<ElectricityBalance>(_K.lastBalance, newV);

  List<String>? get searchHistory => box.safeGet(_K.searchHistory);

  set searchHistory(List<String>? newV) {
    if (newV != null) {
      newV = newV.sublist(0, min(newV.length, maxHistoryLength));
    }
    box.safePut(_K.searchHistory, newV);
  }

  DateTime? get lastUpdateTime => box.safeGet<DateTime>(_K.lastUpdateTime);

  set lastUpdateTime(DateTime? newV) => box.safePut<DateTime>(_K.lastUpdateTime, newV);

  late final $lastUpdateTime = box.provider<DateTime>(_K.lastUpdateTime);

  ValueListenable listenLastUpdateTime() => box.listenable(keys: [_K.lastUpdateTime]);
}
