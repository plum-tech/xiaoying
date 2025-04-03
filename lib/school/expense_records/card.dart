import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/design/widget/app.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:mimir/school/event.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/utils/async_event.dart';
import 'init.dart';
import 'widget/balance.dart';
import 'package:rettulf/rettulf.dart';

import "i18n.dart";
import 'widget/transaction.dart';
import 'x.dart';

class ExpenseRecordsAppCard extends ConsumerStatefulWidget {
  const ExpenseRecordsAppCard({super.key});

  @override
  ConsumerState<ExpenseRecordsAppCard> createState() => _ExpenseRecordsAppCardState();
}

class _ExpenseRecordsAppCardState extends ConsumerState<ExpenseRecordsAppCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late final EventSubscription $refreshEvent;

  @override
  void initState() {
    super.initState();
    $refreshEvent = schoolEventBus.addListener(() async {
      await refresh(active: true);
    });
    if (Settings.school.expense.autoRefresh) {
      refresh(active: false);
    }
  }

  @override
  void dispose() {
    $refreshEvent.cancel();
    super.dispose();
  }

  Future<void> refresh({required bool active}) async {
    final credentials = ref.read(CredentialsInit.storage.oa.$credentials);
    if (credentials == null) return;
    try {
      await XExpense.fetchAndSaveTransactionUntilNow(
        oaAccount: credentials.account,
      );
    } catch (error) {
      if (active) {
        if (!mounted) return;
        context.showSnackBar(content: i18n.refreshFailedTip.text());
      }
      return;
    }
    if (active) {
      if (!mounted) return;
      context.showSnackBar(content: i18n.refreshSuccessTip.text());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.listen(CredentialsInit.storage.oa.$credentials, (pre, next) {
      refresh(active: false);
    });
    final storage = ExpenseRecordsInit.storage;
    final lastUpdateTime = ref.watch(storage.$lastUpdateTime);
    final lastTransaction = ref.watch(storage.$lastTransaction);
    return AppCard(
      view: lastTransaction == null
          ? const SizedBox.shrink()
          : [
              BalanceCard(
                balance: lastTransaction.balanceAfter,
              ).expanded(),
              TransactionCard(
                transaction: lastTransaction,
              ).expanded(),
            ].row().sized(h: 140),
      title: i18n.title.text(),
      subtitle: lastUpdateTime != null ? i18n.lastUpdateTime(context.formatMdhmNum(lastUpdateTime)).text() : null,
      leftActions: [
        FilledButton.icon(
          icon: const Icon(Icons.assignment),
          onPressed: () async {
            context.push("/expense-records");
          },
          label: i18n.list.text(),
        ),
        FilledButton.tonal(
          onPressed: lastTransaction == null
              ? null
              : () async {
                  context.push("/expense-records/statistics");
                },
          child: i18n.statistics.text(),
        ),
      ],
    );
  }
}
