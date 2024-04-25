import 'package:sit/l10n/time.dart';

import 'timetable.dart';
import 'timetable_entity.dart';

sealed class TimetableIssue {}

class TimetableEmptyIssue implements TimetableIssue {
  const TimetableEmptyIssue();
}

/// Credit by Examination
class TimetableCbeIssue implements TimetableIssue {
  final int courseKey;

  const TimetableCbeIssue({
    required this.courseKey,
  });

  static bool detectCbe(SitCourse course) {
    if (course.courseName.contains("自修")) {
      return true;
    }
    return false;
  }
}

class TimetableCourseOverlapIssue implements TimetableIssue {
  final List<String> courseKeys;
  final int weekIndex;
  final Weekday weekday;
  final ({int start, int end}) timeslots;

  const TimetableCourseOverlapIssue({
    required this.courseKeys,
    required this.weekIndex,
    required this.weekday,
    required this.timeslots,
  });
}

/// Two or more lessons in the same course overlap.
class TimetableDuplicateCourseOverlapIssue implements TimetableIssue {
  const TimetableDuplicateCourseOverlapIssue();
}

extension SitTimetable4IssueX on SitTimetable {
  List<TimetableIssue> inspect() {
    final issues = <TimetableIssue>[];
    // check if empty
    if (courses.isEmpty) {
      issues.add(const TimetableEmptyIssue());
    }

    // check if any cbe
    for (final course in courses.values) {
      if (TimetableCbeIssue.detectCbe(course)) {
        issues.add(TimetableCbeIssue(
          courseKey: course.courseKey,
        ));
      }
    }

    // TODO: finish overlap issue inspection
    final entity = resolve();
    for (final week in entity.weeks) {
      for (final day in week.days) {
        for (var timeslot = 0; timeslot < day.timeslot2LessonSlot.length; timeslot++) {
          final lessonSlot = day.timeslot2LessonSlot[timeslot];
          if (lessonSlot.lessons.length >= 2) {
            issues.add(TimetableCourseOverlapIssue(
              courseKeys: lessonSlot.lessons.map((l) => l.course.courseCode).toList(),
              weekIndex: week.index,
              weekday: Weekday.values[day.index],
              timeslots: (start: timeslot, end: timeslot),
            ));
          }
        }
      }
    }
    return issues;
  }
}
