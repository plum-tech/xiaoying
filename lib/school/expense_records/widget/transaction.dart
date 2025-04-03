import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:rettulf/rettulf.dart';
import '../entity/local.dart';
import "../i18n.dart";

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile(this.transaction, {super.key});

  @override
  Widget build(BuildContext context) {
    final title = transaction.bestTitle;
    return ListTile(
      title: Text(title ?? i18n.unknown, style: context.textTheme.titleSmall),
      subtitle: [
        context.formatYmdhmsNum(transaction.timestamp).text(),
        if (title != transaction.note && transaction.note.isNotEmpty) transaction.note.text(),
      ].column(caa: CrossAxisAlignment.start),
      leading: transaction.type.icon.make(color: transaction.type.resolveColor(context), size: 32),
      trailing: transaction.toReadableString().text(
            style: context.textTheme.titleLarge?.copyWith(color: transaction.billColor),
          ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final billColor = transaction.isConsume ? null : transaction.billColor;
    return [
      [
        Icon(
          transaction.type.icon,
          color: transaction.type.resolveColor(context),
        ).padOnly(r: 8),
        AutoSizeText(
          context.formatMdhmNum(transaction.timestamp),
          style: textTheme.titleMedium,
          maxLines: 1,
        ).expanded(),
      ].row(),
      [
        AutoSizeText(
          transaction.toReadableString(),
          style: textTheme.displayMedium?.copyWith(color: billColor),
          maxLines: 1,
        ).expanded(),
        AutoSizeText(
          i18n.view.rmb,
          style: textTheme.titleMedium?.copyWith(color: billColor),
          maxLines: 1,
        ),
      ].row(caa: CrossAxisAlignment.end),
      AutoSizeText(
        transaction.shortDeviceName(),
        style: textTheme.titleMedium,
        maxLines: 1,
      ),
    ]
        .column(
          caa: CrossAxisAlignment.start,
          maa: MainAxisAlignment.spaceEvenly,
        )
        .padAll(10)
        .inCard();
  }
}
