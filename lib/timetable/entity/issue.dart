import 'package:mimir/l10n/time.dart';
import 'package:statistics/statistics.dart';

import 'timetable.dart';

enum TimetableIssueType {
  empty,
  cbeCourse,
  courseOverlaps,
  ;
}

sealed class TimetableIssue {
  TimetableIssueType get type;
}

class TimetableEmptyIssue implements TimetableIssue {
  @override
  TimetableIssueType get type => TimetableIssueType.empty;

  const TimetableEmptyIssue();
}

/// Credit by Examination
class TimetableCbeIssue implements TimetableIssue {
  @override
  TimetableIssueType get type => TimetableIssueType.cbeCourse;
  final int courseKey;

  const TimetableCbeIssue({
    required this.courseKey,
  });

  static bool detect(Course course) {
    if (course.courseName.contains("自修") || course.courseName.contains("免听")) {
      return true;
    }
    return false;
  }
}

class TimetableCourseOverlapIssue implements TimetableIssue {
  @override
  TimetableIssueType get type => TimetableIssueType.courseOverlaps;
  final List<int> courseKeys;
  final int weekIndex;
  final Weekday weekday;
  final ({int start, int end}) timeslots;

  const TimetableCourseOverlapIssue({
    required this.courseKeys,
    required this.weekIndex,
    required this.weekday,
    required this.timeslots,
  });

  bool isSameOne(TimetableCourseOverlapIssue other) {
    if (courseKeys.toSet().equalsElements(other.courseKeys.toSet())) {
      return true;
    }
    return false;
  }
}

extension Timetable4IssueX on Timetable {
  List<TimetableIssue> inspect() {
    final issues = <TimetableIssue>[];
    // check if empty
    if (courses.isEmpty) {
      issues.add(const TimetableEmptyIssue());
    }

    // check if any cbe
    for (final course in courses.values) {
      if (!course.hidden && TimetableCbeIssue.detect(course)) {
        issues.add(TimetableCbeIssue(
          courseKey: course.courseKey,
        ));
      }
    }
    return issues;
  }
}
