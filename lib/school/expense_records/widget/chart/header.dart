import 'package:flutter/widgets.dart';
import 'package:rettulf/rettulf.dart';

class ExpenseChartHeader extends StatelessWidget {
  final String upper;
  final String content;
  final String? lower;

  const ExpenseChartHeader({
    super.key,
    required this.upper,
    required this.content,
    this.lower,
  });

  @override
  Widget build(BuildContext context) {
    return [
      ExpenseChartHeaderLabel(upper),
      content.text(style: context.textTheme.titleLarge),
      if (lower != null) ExpenseChartHeaderLabel(lower!),
    ].column(caa: CrossAxisAlignment.start);
  }
}

class ExpenseChartHeaderLabel extends StatelessWidget {
  final String text;

  const ExpenseChartHeaderLabel(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.titleMedium?.copyWith(color: context.theme.disabledColor);
    return text.text(style: style);
  }
}
