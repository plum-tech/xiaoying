import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mimir/utils/hive.dart';
import 'package:mimir/storage/hive/init.dart';

import '../entity/local.dart';

class _K {
  static const transactionTsList = '/transactionTsList';

  static String transaction(DateTime timestamp) {
    final id = (timestamp.millisecondsSinceEpoch ~/ 1000).toRadixString(16);
    return '/transactions/$id';
  }

  // Don't use lastFetchedTs, and just fetch all translations
  // static const lastFetchedTs = "/lastFetchedTs";
  static const lastTransaction = "/lastTransaction";
  static const lastUpdateTime = "/lastUpdateTime";
}

class ExpenseStorage {
  Box get box => HiveInit.expense;

  ExpenseStorage();

  /// 所有交易记录的索引，记录所有的交易时间，需要保证有序，以实现二分查找
  List<DateTime>? get transactionTsList => box.safeGet<List>(_K.transactionTsList)?.cast<DateTime>();

  set transactionTsList(List<DateTime>? newV) => box.safePut<List>(_K.transactionTsList, newV);

  ValueListenable<Box> listenTransactionTsList() => box.listenable(keys: [_K.transactionTsList]);

  /// 通过某个时刻来获得交易记录
  Transaction? getTransactionByTs(DateTime ts) => box.safeGet<Transaction>(_K.transaction(ts));

  setTransactionByTs(DateTime ts, Transaction? transaction) =>
      box.safePut<Transaction>(_K.transaction(ts), transaction);

  Transaction? get lastTransaction => box.safeGet<Transaction>(_K.lastTransaction);

  set lastTransaction(Transaction? v) => box.safePut<Transaction>(_K.lastTransaction, v);

  late final $lastTransaction = box.provider<Transaction>(_K.lastTransaction);

  ValueListenable<Box> listenLastTransaction() => box.listenable(keys: [_K.lastTransaction]);

  DateTime? get lastUpdateTime => box.safeGet<DateTime>(_K.lastUpdateTime);

  set lastUpdateTime(DateTime? newV) => box.safePut<DateTime>(_K.lastUpdateTime, newV);

  late final $lastUpdateTime = box.provider<DateTime>(_K.lastUpdateTime);

  ValueListenable listenLastUpdateTime() => box.listenable(keys: [_K.lastUpdateTime]);
}

extension ExpenseStorageX on ExpenseStorage {
  void clearIndex() {
    transactionTsList = null;
    lastTransaction = null;
  }

  /// Gets the transaction timestamps in range of start to end.
  /// [start] is inclusive.
  /// [end] is exclusive.
  List<DateTime>? getTransactionTsByRange({
    DateTime? start,
    DateTime? end,
  }) {
    final list = transactionTsList;
    if (list == null) return null;
    if (start == null && end == null) return list;
    return list
        .where((e) => start == null || e == start || e.isAfter(start))
        .where((e) => end == null || e.isBefore(end))
        .toList();
  }

  List<Transaction>? getTransactionsByRange({
    DateTime? start,
    DateTime? end,
  }) {
    final timestamps = getTransactionTsByRange(start: start, end: end);
    if (timestamps == null) return null;
    final transactions = <Transaction>[];
    for (final ts in timestamps) {
      final transaction = getTransactionByTs(ts);
      assert(transaction != null, "$ts has no transaction");
      if (transaction != null) transactions.add(transaction);
    }
    return transactions;
  }
}
