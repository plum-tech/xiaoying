import 'package:flutter/material.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:mimir/design/widget/card.dart';
import 'package:mimir/school/widget/course.dart';
import 'package:rettulf/rettulf.dart';
import 'package:text_scroll/text_scroll.dart';

import '../entity/result.pg.dart';
import '../i18n.dart';

class ExamResultPgCard extends StatelessWidget {
  final bool elevated;
  final ExamResultPg result;

  const ExamResultPgCard(
    this.result, {
    super.key,
    required this.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return ListTile(
      isThreeLine: true,
      leading: CourseIcon(courseName: result.courseName),
      titleTextStyle: textTheme.titleMedium,
      title: Text(result.courseName),
      subtitleTextStyle: textTheme.bodyMedium,
      subtitle: [
        '${result.courseType} ${result.teacher}'.text(),
        '${result.examType} | ${i18n.course.credit}: ${result.credit}'.text(),
      ].column(caa: CrossAxisAlignment.start),
      leadingAndTrailingTextStyle: textTheme.labelSmall?.copyWith(
        fontSize: textTheme.bodyLarge?.fontSize,
        color: result.passed ? null : context.$red$,
      ),
      trailing: result.score.toString().text(),
    ).inAnyCard(clip: Clip.hardEdge, type: elevated ? CardVariant.elevated : CardVariant.filled);
  }
}

class ExamResultPgCarouselCard extends StatelessWidget {
  final bool elevated;
  final ExamResultPg result;

  const ExamResultPgCarouselCard(
    this.result, {
    super.key,
    required this.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Card(
      child: [
        CourseIcon(courseName: result.courseName),
        TextScroll(result.courseName),
        result.teacher.text(),
        result.score.toString().text(
              style: textTheme.labelSmall?.copyWith(
                fontSize: textTheme.bodyLarge?.fontSize,
                color: result.passed ? null : context.$red$,
              ),
            ),
      ].column(maa: MainAxisAlignment.center),
    );
  }
}
