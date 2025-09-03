import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/widget/card.dart';
import 'package:mimir/design/widget/expansion_tile.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/l10n/time.dart';
import 'package:mimir/timetable/entity/timetable.dart';
import '../i18n.dart';

class TimetableCourseCard extends StatelessWidget {
  final String courseName;
  final String courseCode;
  final String classCode;
  final Campus campus;
  final List<Course> courses;
  final Color? color;

  const TimetableCourseCard({
    super.key,
    required this.courseName,
    required this.courseCode,
    required this.classCode,
    required this.courses,
    required this.campus,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final allHidden = courses.every((c) => c.hidden);
    final templateStyle = TextStyle(color: allHidden ? context.theme.disabledColor : null);
    return AnimatedExpansionTile(
      title: courseName.text(style: templateStyle),
      subtitle: [
        if (courseCode.isNotEmpty) "${i18n.course.courseCode} $courseCode".text(style: templateStyle),
        if (classCode.isNotEmpty) "${i18n.course.classCode} $classCode".text(style: templateStyle),
      ].column(caa: CrossAxisAlignment.start),
      children: courses.map((course) {
        final weekNumbers = course.weekIndices.l10n();
        final (:begin, :end) = calcBeginEndTimePoint(course.timeslots, campus, course.place);
        return ListTile(
          isThreeLine: true,
          enabled: !course.hidden,
          title: course.place.text(),
          trailing: course.teachers.join(", ").text(),
          subtitle: [
            "${Weekday.fromIndex(course.dayIndex).l10n()} ${begin.l10n(context)}–${end.l10n(context)}".text(),
            ...weekNumbers.map((n) => n.text()),
          ].column(mas: MainAxisSize.min, caa: CrossAxisAlignment.start),
        );
      }).toList(),
    ).inAnyCard(
      clip: Clip.hardEdge,
      type: allHidden ? CardVariant.outlined : CardVariant.filled,
      color: allHidden ? null : color,
    );
  }
}
