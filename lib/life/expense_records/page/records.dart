import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sit/credentials/widgets/oa_scope.dart';
import 'package:sit/life/expense_records/storage/local.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/local.dart';
import '../init.dart';
import '../i18n.dart';
import '../utils.dart';
import '../widget/list.dart';

class ExpenseRecordsPage extends StatefulWidget {
  const ExpenseRecordsPage({super.key});

  @override
  State<ExpenseRecordsPage> createState() => _ExpenseRecordsPageState();
}

class _ExpenseRecordsPageState extends State<ExpenseRecordsPage> {
  final $lastTransaction = ExpenseRecordsInit.storage.listenLastTransaction();
  bool isFetching = false;
  List<Transaction>? records;

  @override
  void initState() {
    super.initState();
    $lastTransaction.addListener(onLatestChanged);
    records = ExpenseRecordsInit.storage.getTransactionsByRange();
  }

  @override
  void dispose() {
    $lastTransaction.removeListener(onLatestChanged);
    super.dispose();
  }

  void onLatestChanged() {
    setState(() {});
  }

  Future<void> refresh() async {
    final oaCredential = context.auth.credentials;
    if (oaCredential == null) return;
    setState(() {
      isFetching = true;
    });
    try {
      await fetchAndSaveTransactionUntilNow(
        studentId: oaCredential.account,
      );
      setState(() {
        records = ExpenseRecordsInit.storage.getTransactionsByRange();
        isFetching = false;
      });
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = this.records;
    final lastTransaction = ExpenseRecordsInit.storage.latestTransaction;
    return Scaffold(
      appBar: AppBar(
        title: lastTransaction == null
            ? i18n.title.text()
            : i18n.balanceInCard(lastTransaction.balanceAfter.toStringAsFixed(2)).text(),
        centerTitle: true,
        bottom: isFetching
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await HapticFeedback.heavyImpact();
          await refresh();
        },
        child: records == null ? const SizedBox() : TransactionList(records: records),
      ),
    );
  }
}
