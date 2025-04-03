import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

class YearMonthSelector extends StatefulWidget {
  final List<int> years;
  final List<int> months;
  final int initialYear;
  final int initialMonth;
  final bool enableAllYears;
  final bool enableAllMonths;

  const YearMonthSelector({
    super.key,
    required this.years,
    required this.months,
    this.enableAllYears = false,
    this.enableAllMonths = false,
    required this.initialYear,
    required this.initialMonth,
  });

  @override
  State<YearMonthSelector> createState() => _YearMonthSelectorState();
}

class _YearMonthSelectorState extends State<YearMonthSelector> {
  late int selectedYear;
  late int selectedMonth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildYearSelector(),
        buildMonthSelector(),
      ],
    );
  }

  Widget buildYearSelector() {
    return DropdownMenu<int>(
      label: "Year".text(),
      initialSelection: widget.initialYear,
      onSelected: (int? selected) {
        if (selected != null && selected != selectedYear) {
          setState(() => selectedYear = selected);
        }
      },
      dropdownMenuEntries: widget.years
          .map((year) => DropdownMenuEntry<int>(
                value: year,
                label: "$year–${year + 1}",
              ))
          .toList(),
    );
  }

  Widget buildMonthSelector() {
    return DropdownMenu<int>(
      label: "Month".text(),
      initialSelection: widget.initialMonth,
      onSelected: (int? selected) {
        if (selected != null && selected != selectedYear) {
          setState(() => selectedYear = selected);
        }
      },
      dropdownMenuEntries: widget.months
          .map((month) => DropdownMenuEntry<int>(
                value: month,
                label: month.toString(),
              ))
          .toList(),
    );
  }
}
