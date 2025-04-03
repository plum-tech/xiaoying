import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/widget/common.dart';
import 'package:mimir/design/widget/grouped.dart';
import 'package:mimir/design/widget/multi_select.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/exam_result/entity/gpa.dart';
import 'package:mimir/school/exam_result/entity/result.ug.dart';
import 'package:mimir/school/exam_result/init.dart';
import 'package:mimir/school/exam_result/page/details.gpa.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:text_scroll/text_scroll.dart';

import '../i18n.dart';
import '../utils.dart';

class GpaCalculatorPage extends ConsumerStatefulWidget {
  const GpaCalculatorPage({super.key});

  @override
  ConsumerState<GpaCalculatorPage> createState() => _GpaCalculatorPageState();
}

typedef _GpaGroups = ({
  List<({SemesterInfo semester, List<ExamResultGpaItem> items})> groups,
  List<ExamResultGpaItem> list
});

_GpaGroups? _buildGpaItems(List<ExamResultUg>? resultList) {
  if (resultList == null) return null;
  final gpaItems = extractExamResultGpaItems(resultList);
  final groups = groupExamResultGpaItems(gpaItems);
  return (groups: groups, list: gpaItems);
}

final _gpaItems = Provider.autoDispose((ref) {
  final all = ref.watch(ExamResultInit.ugStorage.$resultListFamily(SemesterInfo.all));
  final items = _buildGpaItems(all);
  return items;
});

class _GpaCalculatorPageState extends ConsumerState<GpaCalculatorPage> {
  final $selected = ValueNotifier(const <ExamResultGpaItem>[]);
  final multiselect = MultiselectController<ExamResultGpaItem>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    multiselect.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gpaItems = ref.watch(_gpaItems);
    return Scaffold(
      body: MultiselectScope<ExamResultGpaItem>(
        controller: multiselect,
        dataSource: gpaItems?.list ?? const [],
        onSelectionChanged: (indexes, items) {
          $selected.value = items;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: buildTitle(),
              actions: [
                PlatformTextButton(
                  onPressed: () {
                    multiselect.clearSelection();
                  },
                  child: Text(i18n.cancel),
                )
              ],
            ),
            if (gpaItems != null)
              if (gpaItems.groups.isEmpty)
                SliverFillRemaining(
                  child: LeavingBlank(
                    icon: Icons.inbox_outlined,
                    desc: i18n.noResultsTip,
                  ),
                ),
            if (gpaItems != null)
              ...gpaItems.groups.map((e) => ExamResultGroupBySemester(
                    semester: e.semester,
                    items: e.items,
                  )),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        child: buildCourseCatChoices().sized(h: 40),
      ),
    );
  }

  Widget buildTitle() {
    return $selected >>
        (ctx, selected) => selected.isEmpty
            ? i18n.gpa.title.text()
            : TextScroll(_buildGpaText(
                items: selected,
                showSelectedCount: false,
              ));
  }

  Widget buildCourseCatChoices() {
    final gpaItems = ref.watch(_gpaItems);
    return $selected >>
        (ctx, selected) {
          return ListView(
            scrollDirection: Axis.horizontal,
            physics: const RangeMaintainingScrollPhysics(),
            children: [
              ActionChip(
                label: i18n.gpa.selectAll.text(),
                onPressed: selected.length != gpaItems?.list.length
                    ? () {
                        multiselect.selectAll();
                      }
                    : null,
              ).padH(4),
              ActionChip(
                label: i18n.gpa.invert.text(),
                onPressed: () {
                  multiselect.invertSelection();
                },
              ).padH(4),
              ActionChip(
                label: i18n.gpa.exceptGenEd.text(),
                onPressed: selected.any((item) => item.courseCat == CourseCat.genEd)
                    ? () {
                        multiselect.setSelectedIndexes(selected
                            .where((item) => item.courseCat != CourseCat.genEd)
                            .map((item) => item.index)
                            .toList());
                      }
                    : null,
              ).padH(4),
              ActionChip(
                label: i18n.gpa.exceptFailed.text(),
                onPressed: selected.any((item) => !item.passed)
                    ? () {
                        multiselect.setSelectedIndexes(
                            selected.where((item) => item.passed).map((item) => item.index).toList());
                      }
                    : null,
              ).padH(4),
            ],
          );
        };
  }
}

class ExamResultGroupBySemester extends StatefulWidget {
  final SemesterInfo semester;
  final List<ExamResultGpaItem> items;

  const ExamResultGroupBySemester({
    super.key,
    required this.semester,
    required this.items,
  });

  @override
  State<ExamResultGroupBySemester> createState() => _ExamResultGroupBySemesterState();
}

class _ExamResultGroupBySemesterState extends State<ExamResultGroupBySemester> {
  @override
  Widget build(BuildContext context) {
    final scope = MultiselectScope.controllerOf<ExamResultGpaItem>(context);
    final selectedIndicesSet = scope.selectedIndexes.toSet();
    final indicesOfGroup = widget.items.map((item) => item.index).toSet();
    final intersection = selectedIndicesSet.intersection(indicesOfGroup);
    final selectedItems = intersection.map((i) => scope[i]).toList();
    final isGroupNoneSelected = intersection.isEmpty;
    final isGroupAllSelected = intersection.length == indicesOfGroup.length;
    return GroupedSection(
        headerBuilder: (context, expanded, toggleExpand, defaultTrailing) {
          return ListTile(
            leading: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            title: widget.semester.l10n().text(),
            subtitle: _buildGpaText(items: selectedItems).text(),
            titleTextStyle: context.textTheme.titleMedium,
            onTap: toggleExpand,
            trailing: PlatformIconButton(
              icon: Icon(
                isGroupNoneSelected
                    ? context.icons.checkBoxBlankOutlineRounded
                    : isGroupAllSelected
                        ? context.icons.checkBoxCheckedOutlineRounded
                        : context.icons.checkBoxIndeterminateOutlineRounded,
              ),
              onPressed: () {
                for (final item in widget.items) {
                  if (isGroupAllSelected) {
                    scope.unselect(item.index);
                  } else {
                    scope.select(item.index);
                  }
                }
              },
            ),
          );
        },
        itemCount: widget.items.length,
        itemBuilder: (ctx, i) {
          final item = widget.items[i];
          final selected = scope.isSelectedIndex(item.index);
          return ExamResultGpaTile(
            item,
            selected: selected,
            onTap: () {
              scope.toggle(item.index);
            },
            onLongPress: () async {
              await ctx.showSheet((ctx) => ExamResultGpaItemDetailsPage(item));
            },
          ).inFilledCard(clip: Clip.hardEdge);
        });
  }
}

class ExamResultGpaTile extends StatelessWidget {
  final ExamResultGpaItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  const ExamResultGpaTile(
    this.item, {
    super.key,
    this.onTap,
    this.onLongPress,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final result = item.initial;
    assert(item.maxScore != null);
    final score = item.maxScore ?? 0.0;
    return ListTile(
      isThreeLine: true,
      selected: selected,
      leading: Icon(selected ? context.icons.checkBoxCheckedOutlineRounded : context.icons.checkBoxBlankOutlineRounded)
          .padAll(8),
      titleTextStyle: textTheme.titleMedium,
      title: Text(result.courseName),
      subtitleTextStyle: textTheme.bodyMedium,
      subtitle: [
        '${i18n.course.credit}: ${result.credit}'.text(),
        if (result.teachers.isNotEmpty) result.teachers.join(", ").text(),
      ].column(caa: CrossAxisAlignment.start, mas: MainAxisSize.min),
      leadingAndTrailingTextStyle: textTheme.labelSmall?.copyWith(
        fontSize: textTheme.bodyLarge?.fontSize,
        color: item.passed ? null : context.$red$,
      ),
      trailing: score.toString().text(),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

String _buildGpaText({
  required List<ExamResultGpaItem> items,
  bool showSelectedCount = true,
}) {
  if (items.isEmpty) {
    return i18n.gpa.lessonSelected(items.length);
  }
  final validItems = items.map((item) {
    final maxScore = item.maxScore;
    if (maxScore == null) return null;
    return (score: maxScore, credit: item.credit);
  }).nonNulls;
  final (:gpa, :credit) = calcGPA(validItems);
  var text = "${i18n.gpa.credit(credit)} ${i18n.gpa.gpaResult(gpa)}";
  if (showSelectedCount) {
    text = "${i18n.gpa.lessonSelected(items.length)} $text";
  }
  return text;
}
