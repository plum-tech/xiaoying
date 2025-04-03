import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:mimir/design/widget/expansion_tile.dart';
import 'package:mimir/l10n/time.dart';

import '../entity/timetable.dart';
import '../entity/issue.dart';
import '../page/edit/course_editor.dart';
import '../i18n.dart';

extension TimetableIssuesX on List<TimetableIssue> {
  List<Widget> build({
    required BuildContext context,
    required Timetable timetable,
    required ValueChanged<Timetable> onTimetableChanged,
  }) {
    final empty = whereType<TimetableEmptyIssue>().toList();
    final cbe = whereType<TimetableCbeIssue>().toList();
    final courseOverlap = whereType<TimetableCourseOverlapIssue>().toList();
    return [
      if (empty.isNotEmpty)
        TimetableEmptyIssueWidget(
          issues: empty,
        ),
      if (cbe.isNotEmpty)
        TimetableCbeIssueWidget(
          issues: cbe,
          timetable: timetable,
          onTimetableChanged: onTimetableChanged,
        ),
      if (courseOverlap.isNotEmpty)
        TimetableCourseOverlapIssueWidget(
          issues: courseOverlap,
          timetable: timetable,
          onTimetableChanged: onTimetableChanged,
        ),
    ];
  }
}

class TimetableEmptyIssueWidget extends StatelessWidget {
  final List<TimetableEmptyIssue> issues;

  const TimetableEmptyIssueWidget({
    super.key,
    required this.issues,
  });

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        title: TimetableIssueType.empty.l10n().text(),
        subtitle: TimetableIssueType.empty.l10nDesc().text(),
      ),
    );
  }
}

class TimetableCbeIssueWidget extends StatefulWidget {
  final List<TimetableCbeIssue> issues;
  final Timetable timetable;
  final ValueChanged<Timetable> onTimetableChanged;

  const TimetableCbeIssueWidget({
    super.key,
    required this.issues,
    required this.timetable,
    required this.onTimetableChanged,
  });

  @override
  State<TimetableCbeIssueWidget> createState() => _TimetableCbeIssueWidgetState();
}

class _TimetableCbeIssueWidgetState extends State<TimetableCbeIssueWidget> {
  @override
  Widget build(BuildContext context) {
    final timetable = widget.timetable;
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      child: AnimatedExpansionTile(
        initiallyExpanded: true,
        title: TimetableIssueType.cbeCourse.l10n().text(),
        subtitle: TimetableIssueType.cbeCourse.l10nDesc().text(),
        children: widget.issues.map((issue) {
          final course = timetable.courses["${issue.courseKey}"]!;
          return ListTile(
            title: course.courseName.text(),
            subtitle: [
              course.place.text(),
            ].column(caa: CrossAxisAlignment.start),
            trailing: PlatformTextButton(
              child: i18n.issue.resolve.text(),
              onPressed: () async {
                final newCourse = await context.showSheet<Course>(
                  (ctx) => SitCourseEditorPage(
                    title: i18n.editor.editCourse,
                    course: course,
                    editable: const SitCourseEditable.only(hidden: true),
                  ),
                );
                if (newCourse == null) return;
                final newTimetable = timetable.copyWith(
                  courses: Map.of(timetable.courses)..["${newCourse.courseKey}"] = newCourse,
                );
                widget.onTimetableChanged(newTimetable);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TimetableCourseOverlapIssueWidget extends StatefulWidget {
  final List<TimetableCourseOverlapIssue> issues;
  final Timetable timetable;
  final ValueChanged<Timetable> onTimetableChanged;

  const TimetableCourseOverlapIssueWidget({
    super.key,
    required this.issues,
    required this.timetable,
    required this.onTimetableChanged,
  });

  @override
  State<TimetableCourseOverlapIssueWidget> createState() => _TimetableCourseOverlapIssueWidgetState();
}

class _TimetableCourseOverlapIssueWidgetState extends State<TimetableCourseOverlapIssueWidget> {
  @override
  Widget build(BuildContext context) {
    final timetable = widget.timetable;
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      child: AnimatedExpansionTile(
        initiallyExpanded: true,
        title: TimetableIssueType.courseOverlaps.l10n().text(),
        subtitle: TimetableIssueType.courseOverlaps.l10nDesc().text(),
        children: widget.issues.map((issue) {
          final courses = issue.courseKeys.map((key) => timetable.courses["$key"]).whereType<Course>().toList();
          return ListTile(
            title: courses.map((course) => course.courseName).join(", ").text(),
            subtitle: [
              ...courses.map((course) {
                final (:begin, :end) = calcBeginEndTimePoint(course.timeslots, timetable.campus, course.place);
                return "${Weekday.fromIndex(course.dayIndex).l10n()} ${begin.l10n(context)}–${end.l10n(context)}"
                    .text();
              }),
            ].column(caa: CrossAxisAlignment.start),
          );
        }).toList(),
      ),
    );
  }
}
