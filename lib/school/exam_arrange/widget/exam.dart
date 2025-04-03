import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/adaptive/foundation.dart';

import '../i18n.dart';
import '../entity/exam.dart';

class ExamCardContent extends StatelessWidget {
  final ExamEntry exam;
  final bool enableAddEvent;

  const ExamCardContent(
    this.exam, {
    super.key,
    this.enableAddEvent = false,
  });

  @override
  Widget build(BuildContext context) {
    final time = exam.time;
    final disqualifiedColor = exam.disqualified ? context.$red$ : null;
    return [
      [
        exam.courseName.text(style: context.textTheme.titleMedium?.copyWith(color: disqualifiedColor)),
        [
          if (exam.disqualified)
            Chip(
              label: i18n.disqualified.text(),
              labelStyle: TextStyle(color: disqualifiedColor),
              elevation: 2,
            ),
          if (exam.isRetake)
            Chip(
              label: i18n.retake.text(),
              elevation: 2,
            ),
        ].wrap(spacing: 4),
      ].row(maa: MainAxisAlignment.spaceBetween),
      Divider(color: disqualifiedColor ?? context.colorScheme.onSurfaceVariant),
      ExamEntryDetailsTable(exam),
    ].column(caa: CrossAxisAlignment.start).padSymmetric(v: 15, h: 20);
  }
}

class ExamEntryDetailsTable extends StatelessWidget {
  final ExamEntry exam;

  const ExamEntryDetailsTable(
    this.exam, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final disqualifiedColor = exam.disqualified ? context.$red$ : null;
    final style = context.textTheme.bodyMedium?.copyWith(color: disqualifiedColor);
    final time = exam.time;
    return Table(
      children: [
        TableRow(children: [
          i18n.location.text(style: style),
          exam.place.text(style: style),
        ]),
        if (exam.seatNumber != null)
          TableRow(children: [
            i18n.seatNumber.text(style: style),
            exam.seatNumber.toString().text(style: style),
          ]),
        if (time != null) ...[
          TableRow(children: [
            i18n.date.text(style: style),
            exam.buildDate(context).text(style: style),
          ]),
          TableRow(children: [
            i18n.time.text(style: style),
            exam.buildTime(context).text(style: style),
          ]),
        ],
      ],
    );
  }
}
