import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rettulf/rettulf.dart';

import '../../entity/local.dart';
import '../../entity/statistics.dart';
import "../../i18n.dart";
import 'delegate.dart';
import 'header.dart';

class ExpensePieChart extends StatefulWidget {
  final StatisticsDelegate delegate;

  const ExpensePieChart({
    super.key,
    required this.delegate,
  });

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  StatisticsDelegate get delegate => widget.delegate;

  DateTime get start => delegate.start;

  StatisticsMode get mode => delegate.mode;

  @override
  Widget build(BuildContext context) {
    return [
      ExpensePieChartHeader(
        total: delegate.total,
      ).padFromLTRB(16, 8, 0, 0),
      AspectRatio(
        aspectRatio: 1.5,
        child: ExpensePieChartWidget(
          delegate: delegate,
        ),
      ),
      buildLegends().padAll(8).align(at: Alignment.topLeft),
    ].column(caa: CrossAxisAlignment.start);
  }

  Widget buildLegends() {
    return delegate.type2Stats.entries
        .sortedBy<num>((e) => -e.value.total)
        .map((record) {
          final MapEntry(key: type, value: (records: _, :total, proportion: _)) = record;
          final color = type.resolveColor(context);
          return Chip(
            avatar: Icon(type.icon, color: color),
            labelStyle: TextStyle(color: color),
            label: "${type.l10n()}: ${i18n.unit.rmb(total.toStringAsFixed(2))}".text(),
          );
        })
        .toList()
        .wrap(spacing: 4, runSpacing: 4);
  }
}

class ExpensePieChartHeader extends StatelessWidget {
  final double total;

  const ExpensePieChartHeader({
    super.key,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return ExpenseChartHeader(
      upper: i18n.stats.total,
      content: "¥${total.toStringAsFixed(2)}",
    );
  }
}

class ExpensePieChartWidget extends ConsumerStatefulWidget {
  final StatisticsDelegate delegate;

  const ExpensePieChartWidget({
    super.key,
    required this.delegate,
  });

  @override
  ConsumerState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends ConsumerState<ExpensePieChartWidget> {
  StatisticsDelegate get delegate => widget.delegate;
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        sectionsSpace: 0,
        centerSpaceRadius: 60,
        sections: delegate.type2Stats.entries.mapIndexed((i, entry) {
          final isTouched = i == touchedIndex;
          final MapEntry(key: type, value: (records: _, :total, :proportion)) = entry;
          final color = type.resolveColor(context);
          return PieChartSectionData(
            color: color.withOpacity(isTouched ? 1 : 0.8),
            value: total,
            title: "${(proportion * 100).toStringAsFixed(2)}%",
            titleStyle: context.textTheme.titleSmall,
            radius: isTouched ? 55 : 50,
            badgeWidget: Icon(type.icon, color: color),
            badgePositionPercentageOffset: 1.5,
          );
        }).toList(),
      ),
    );
  }
}

class ExpenseAverageTile extends StatelessWidget {
  final TransactionType type;
  final double average;
  final double max;

  const ExpenseAverageTile({
    super.key,
    required this.type,
    required this.average,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(type.icon, color: type.resolveColor(context)),
      title: i18n.stats.averageSpendIn(amount: "¥${average.toStringAsFixed(2)}", type: type).text(),
      subtitle: i18n.stats.maxSpendOf(amount: "¥${max.toStringAsFixed(2)}").text(),
    );
  }
}
