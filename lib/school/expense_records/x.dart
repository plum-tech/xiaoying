import 'entity/local.dart';
import 'init.dart';

class XExpense {
  static Future<void> fetchAndSaveTransactionUntilNow({
    required String oaAccount,
  }) async {
    final storage = ExpenseRecordsInit.storage;
    final now = DateTime.now();
    final start = now.copyWith(year: now.year - 6);
    final newlyFetched = await ExpenseRecordsInit.service.fetch(
      studentID: oaAccount,
      from: start,
      to: now,
    );
    storage.lastUpdateTime = DateTime.now();
    final oldTsList = storage.transactionTsList ?? const [];
    final newTsList = {...newlyFetched.map((e) => e.timestamp), ...oldTsList}.toList();
    // the latest goes first
    newTsList.sort((a, b) => -a.compareTo(b));
    for (final transaction in newlyFetched) {
      storage.setTransactionByTs(transaction.timestamp, transaction);
    }
    storage.transactionTsList = newTsList;
    final latest = newlyFetched.firstOrNull;
    if (latest != null) {
      final latestValidBalance = _findLatestValidBalanceTransaction(newlyFetched, newTsList);
      // check if the transaction is kept for topping up
      if (latestValidBalance != null) {
        storage.lastTransaction = latest.copyWith(
          balanceBefore: latestValidBalance.balanceBefore,
          balanceAfter: latestValidBalance.balanceAfter,
        );
      } else {
        storage.lastTransaction = latest;
      }
    }
  }

  /// [newlyFetched] is descending by time.
  static Transaction? _findLatestValidBalanceTransaction(List<Transaction> newlyFetched, List<DateTime> allTsList) {
    for (final transaction in newlyFetched) {
      if (transaction.type != TransactionType.topUp &&
          transaction.balanceBefore != 0 &&
          transaction.balanceAfter != 0) {
        return transaction;
      }
    }
    for (final ts in allTsList) {
      final transaction = ExpenseRecordsInit.storage.getTransactionByTs(ts);
      if (transaction == null) continue;
      if (transaction.type != TransactionType.topUp &&
          transaction.balanceBefore != 0 &&
          transaction.balanceAfter != 0) {
        return transaction;
      }
    }
    return null;
  }
}
