import 'package:flutter/material.dart';
import 'package:mimir/design/animation/number.dart';
import '../entity/balance.dart';
import 'package:rettulf/rettulf.dart';

import '../i18n.dart';

class ElectricityBalanceCard extends StatelessWidget {
  final ElectricityBalance balance;
  final double? warningBalance;
  final Color warningColor;

  const ElectricityBalanceCard({
    super.key,
    required this.balance,
    this.warningBalance = 10.0,
    this.warningColor = Colors.redAccent,
  });

  @override
  Widget build(BuildContext context) {
    final warningBalance = this.warningBalance;
    final balance = this.balance;
    final balanceColor = warningBalance == null || warningBalance < balance.balance ? null : warningColor;
    final style = context.textTheme.titleMedium;
    return [
      ListTile(
        leading: const Icon(Icons.offline_bolt),
        titleTextStyle: style,
        title: i18n.remainingPower.text(),
        trailing: AnimatedNumber(
          value: balance.remainingPower,
          builder: (ctx, value) => i18n.unit.powerKwh(value.toStringAsFixed(2)).text(style: style),
        ),
      ),
      ListTile(
        leading: Icon(Icons.savings, color: balanceColor),
        titleTextStyle: style?.copyWith(color: balanceColor),
        title: i18n.balance.text(),
        trailing: AnimatedNumber(
          value: balance.balance,
          builder: (ctx, value) => i18n.unit.rmb(value.toStringAsFixed(2)).text(
                style: style?.copyWith(color: balanceColor),
              ),
        ),
      ),
    ].column(maa: MainAxisAlignment.spaceEvenly).inCard();
  }
}
