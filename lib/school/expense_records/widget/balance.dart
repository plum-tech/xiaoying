import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mimir/design/animation/number.dart';
import 'package:mimir/utils/format.dart';
import 'package:rettulf/rettulf.dart';
import "../i18n.dart";

class BalanceCard extends StatelessWidget {
  final double balance;
  final bool removeTrailingZeros;
  final double? warningBalance;
  final Color warningColor;

  const BalanceCard({
    super.key,
    required this.balance,
    this.warningBalance = 10.0,
    this.warningColor = Colors.redAccent,
    this.removeTrailingZeros = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final warningBalance = this.warningBalance;
    final balanceColor = warningBalance == null || warningBalance < balance ? null : warningColor;
    return [
      AutoSizeText(
        i18n.view.balance,
        style: textTheme.titleLarge,
        maxLines: 1,
      ),
      AnimatedNumber(
          value: balance,
          builder: (context, balance) {
            return AutoSizeText(
              removeTrailingZeros ? formatWithoutTrailingZeros(balance) : balance.toStringAsFixed(2),
              style: textTheme.displayMedium?.copyWith(color: balanceColor),
              maxLines: 1,
            );
          }),
      AutoSizeText(
        i18n.view.rmb,
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
