import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/school/utils.dart';

import '../entity/school.dart';
import "../i18n.dart";

class SemesterSelector extends StatefulWidget {
  final int? baseYear;
  final SemesterInfo? initial;
  final bool showEntireYear;
  final bool showNextYear;
  final void Function(SemesterInfo newSelection)? onSelected;

  const SemesterSelector({
    super.key,
    required this.baseYear,
    this.onSelected,
    this.initial,
    this.showNextYear = false,
    this.showEntireYear = false,
  });

  @override
  State<StatefulWidget> createState() => _SemesterSelectorState();
}

class _SemesterSelectorState extends State<SemesterSelector> {
  late final DateTime now;

  /// 四位年份
  late int selectedYear;

  /// 要查询的学期
  late Semester selectedSemester;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    selectedYear = widget.initial?.year ?? estimateSchoolYear();
    if (widget.showEntireYear) {
      selectedSemester = widget.initial?.semester ?? Semester.all;
    } else {
      selectedSemester = widget.initial?.semester ?? estimateSemester();
    }
  }

  @override
  Widget build(BuildContext context) {
    return [
      buildYearSelector().padH(4),
      buildSemesterSelector().padH(4),
    ].row(caa: CrossAxisAlignment.start, mas: MainAxisSize.min).padSymmetric(v: 5).center();
  }

  /// generate semesters in reverse order
  List<int> _generateYearList() {
    var endYear = estimateSchoolYear();
    if (widget.showNextYear) {
      endYear += 1;
    }
    final yearItems = <int>[];
    for (var year = widget.baseYear ?? now.year; year <= endYear; year++) {
      yearItems.add(year);
    }
    yearItems.sort();
    return yearItems.reversed.toList();
  }

  Widget buildYearSelector() {
    final List<int> yearList = _generateYearList().toList();

    return DropdownMenu<int>(
      label: i18n.course.schoolYear.text(),
      initialSelection: selectedYear,
      onSelected: (int? newSelection) {
        if (newSelection != null && newSelection != selectedYear) {
          setState(() => selectedYear = newSelection);
          widget.onSelected?.call(SemesterInfo(year: newSelection, semester: selectedSemester));
        }
      },
      dropdownMenuEntries: yearList
          .map((year) => DropdownMenuEntry<int>(
                value: year,
                label: "$year–${year + 1}",
              ))
          .toList(),
    );
  }

  Widget buildSemesterSelector() {
    List<Semester> semesters = widget.showEntireYear
        ? const [Semester.all, Semester.term1, Semester.term2]
        : const [Semester.term1, Semester.term2];
    return DropdownMenu<Semester>(
      label: i18n.course.semester.text(),
      initialSelection: selectedSemester,
      onSelected: (Semester? newSelection) {
        if (newSelection != null && newSelection != selectedSemester) {
          setState(() => selectedSemester = newSelection);
          widget.onSelected?.call(SemesterInfo(year: selectedYear, semester: newSelection));
        }
      },
      dropdownMenuEntries: semesters
          .map((semester) => DropdownMenuEntry<Semester>(
                value: semester,
                label: semester.l10n(),
              ))
          .toList(),
    );
  }
}
