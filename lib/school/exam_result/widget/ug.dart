import 'package:flutter/material.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:mimir/school/exam_result/page/details.ug.dart';
import 'package:mimir/school/widget/course.dart';
import 'package:rettulf/rettulf.dart';

import '../i18n.dart';
import '../entity/result.ug.dart';

class ExamResultUgTile extends StatelessWidget {
  final ExamResultUg result;

  const ExamResultUgTile(
    this.result, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final score = result.score;
    return ListTile(
      isThreeLine: true,
      leading: CourseIcon(courseName: result.courseName),
      titleTextStyle: textTheme.titleMedium,
      title: Text(result.courseName),
      subtitleTextStyle: textTheme.bodyMedium,
      subtitle: [
        result.examType.l10n().text(),
        if (result.teachers.isNotEmpty) result.teachers.join(", ").text(),
      ].column(caa: CrossAxisAlignment.start, mas: MainAxisSize.min),
      leadingAndTrailingTextStyle: textTheme.labelSmall?.copyWith(
        fontSize: textTheme.bodyLarge?.fontSize,
        color: result.passed ? null : context.$red$,
      ),
      trailing: score != null ? score.toString().text() : i18n.courseNotEval.text(),
      onTap: () async {
        context.showSheet((ctx) => ExamResultUgDetailsPage(result));
      },
    );
  }
}
