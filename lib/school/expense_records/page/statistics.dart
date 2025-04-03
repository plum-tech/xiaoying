import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/widget/grouped.dart';
import 'package:mimir/school/expense_records/entity/statistics.dart';
import 'package:mimir/school/expense_records/storage/local.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/school/expense_records/utils.dart';
import 'package:mimir/utils/collection.dart';
import 'package:mimir/utils/date.dart';
import 'package:statistics/statistics.dart';

import '../entity/local.dart';
import '../i18n.dart';
import '../init.dart';
import '../widget/chart/bar.dart';
import '../widget/chart/delegate.dart';
import '../widget/chart/header.dart';
import '../widget/chart/pie.dart';
import '../widget/transaction.dart';

class ExpenseStatisticsPage extends ConsumerStatefulWidget {
  const ExpenseStatisticsPage({super.key});

  @override
  ConsumerState<ExpenseStatisticsPage> createState() => _ExpenseStatisticsPageState();
}

typedef Type2transactions = Map<TransactionType, ({List<Transaction> records, double total, double proportion})>;

final _allRecords = Provider.autoDispose((ref) {
  final all = ExpenseRecordsInit.storage.getTransactionsByRange() ?? const [];
  all.retainWhere((record) => record.type.isConsume);
  return all;
});

final _statisticsMode = StateProvider.autoDispose<StatisticsMode>((ref) => StatisticsMode.week);

final _startTime2Records = Provider.autoDispose((ref) {
  final mode = ref.watch(_statisticsMode);
  final all = ref.watch(_allRecords);
  return mode.resort(all);
});

class _ExpenseStatisticsPageState extends ConsumerState<ExpenseStatisticsPage> {
  late int index = ref.read(_startTime2Records).length - 1;
  final controller = ScrollController();
  final $showTimeSpan = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      final pos = controller.positions.last;
      final showTimeSpan = $showTimeSpan.value;
      if (pos.pixels > pos.minScrollExtent) {
        if (!showTimeSpan) {
          setState(() {
            $showTimeSpan.value = true;
          });
        }
      } else {
        if (showTimeSpan) {
          setState(() {
            $showTimeSpan.value = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(_statisticsMode);
    final startTime2Records = ref.watch(_startTime2Records);
    ref.listen(_startTime2Records, (previous, next) {
      setState(() {
        index = next.length - 1;
      });
    });
    final current = startTime2Records.indexAt(index);
    assert(current.records.every((type) => type.isConsume));
    final type2Records = current.records.groupListsBy((r) => r.type).entries.toList();
    final delegate = StatisticsDelegate.byMode(
      mode,
      start: current.start,
      records: current.records,
    );
    return Scaffold(
      appBar: AppBar(
        title: i18n.stats.title.text(),
      ),
      body: [
        CustomScrollView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverList.list(children: [
              buildModeSelector(mode).padSymmetric(h: 16, v: 4),
              ExpenseBarChart(delegate: delegate),
              const Divider(),
              ExpensePieChart(delegate: delegate),
              const Divider(),
              ExpenseChartHeaderLabel(i18n.stats.summary).padFromLTRB(16, 8, 0, 0),
            ]),
            SliverList.builder(
              itemCount: type2Records.length,
              itemBuilder: (ctx, i) {
                final e = type2Records[i];
                final amounts = e.value.map((e) => e.deltaAmount).toList();
                return ExpenseAverageTile(
                  average: amounts.mean,
                  max: amounts.max,
                  type: e.key,
                );
              },
            ),
            SliverList.list(children: [
              const Divider(),
              ExpenseChartHeaderLabel(i18n.stats.details).padFromLTRB(16, 8, 0, 0),
            ]),
            if (mode != StatisticsMode.day)
              ...mode.downgrade.resort(current.records).map((e) {
                return GroupedSection(
                  headerBuilder: (context, expanded, toggleExpand, defaultTrailing) {
                    return ListTile(
                      title: formatDateSpan(
                        from: e.start,
                        to: mode.downgrade.getAfterUnitTime(start: e.start),
                      ).text(),
                      onTap: toggleExpand,
                      trailing: defaultTrailing,
                    );
                  },
                  itemCount: e.records.length,
                  itemBuilder: (ctx, i) {
                    final record = e.records[i];
                    return TransactionTile(record);
                  },
                );
              })
            else
              SliverList.builder(
                itemCount: current.records.length,
                itemBuilder: (ctx, i) {
                  final record = current.records[i];
                  return TransactionTile(record);
                },
              ),
          ],
        ),
        $showTimeSpan >>
            (ctx, showTimeSpan) => AnimatedSlide(
                  offset: showTimeSpan ? Offset.zero : const Offset(0, -2),
                  duration: Durations.long4,
                  child: AnimatedSwitcher(
                    duration: Durations.long4,
                    child: showTimeSpan ? buildHeader(current.start) : null,
                  ),
                ).align(at: Alignment.topCenter),
      ].stack(),
    );
  }

  Widget buildModeSelector(StatisticsMode selected) {
    return SegmentedButton<StatisticsMode>(
      showSelectedIcon: false,
      segments: StatisticsMode.values
          .map((e) => ButtonSegment<StatisticsMode>(
                value: e,
                label: e.l10nName().text(),
              ))
          .toList(),
      selected: <StatisticsMode>{selected},
      onSelectionChanged: (newSelection) {
        ref.read(_statisticsMode.notifier).state = newSelection.first;
      },
    );
  }

  Widget buildHeader(DateTime start) {
    final startTime2Records = ref.watch(_startTime2Records);
    final mode = ref.watch(_statisticsMode);
    return Card.filled(
      child: [
        PlatformIconButton(
          onPressed: index > 0
              ? () {
                  setState(() {
                    index = index - 1;
                  });
                }
              : null,
          icon: Icon(context.icons.leftChevron),
        ),
        resolveTime4Display(context: context, mode: mode, date: start).text(),
        PlatformIconButton(
          onPressed: index < startTime2Records.length - 1
              ? () {
                  setState(() {
                    index = index + 1;
                  });
                }
              : null,
          icon: Icon(context.icons.rightChevron),
        ),
      ].row(maa: MainAxisAlignment.spaceBetween),
    );
  }
}
