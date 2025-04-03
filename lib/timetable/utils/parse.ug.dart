import 'package:mimir/backend/entity/user.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/utils/strings.dart';
import 'package:uuid/uuid.dart';

import '../entity/course.dart';
import '../entity/timetable.dart';
import '../i18n.dart';
import '../utils.dart';

final Map<String, int> weekday2Index = {
  '星期一': 0,
  '星期二': 1,
  '星期三': 2,
  '星期四': 3,
  '星期五': 4,
  '星期六': 5,
  '星期日': 6,
};

/// Then the [weekText] could be `1-5周,14周,8-10周(单)`
/// The return value should be
/// ```dart
/// TimetableWeekIndices([
///  TimetableWeekIndex.all(
///    (start: 0, end: 4)
///  ),
///  TimetableWeekIndex.single(
///    13,
///  ),
///  TimetableWeekIndex.odd(
///    (start: 7, end: 9),
///  ),
/// ])
/// ```
TimetableWeekIndices parseWeekText2RangedNumbers(
  String weekText, {
  required String allSuffix,
  required String oddSuffix,
  required String evenSuffix,
}) {
  final weeks = weekText.split(',');
// Then the weeks should be ["1-5周","14周","8-10周(单)"]
  final indices = <TimetableWeekIndex>[];
  for (final week in weeks) {
    // odd week
    if (week.endsWith(oddSuffix)) {
      final rangeText = week.removeSuffix(oddSuffix);
      final range = rangeFromString(rangeText, number2index: true);
      indices.add(TimetableWeekIndex.odd(range));
    } else if (week.endsWith(evenSuffix)) {
      final rangeText = week.removeSuffix(evenSuffix);
      final range = rangeFromString(rangeText, number2index: true);
      indices.add(TimetableWeekIndex.even(range));
    } else if (week.endsWith(allSuffix)) {
      final numberText = week.removeSuffix(allSuffix);
      final range = rangeFromString(numberText, number2index: true);
      indices.add(TimetableWeekIndex.all(range));
    }
  }
  return TimetableWeekIndices(indices);
}

typedef _TimetableInter = ({
  Map<String, Course> courses,
  int lastCourseKey,
});

_TimetableInter _parseUndergraduateTimetableFromCourseRaw(List<UndergraduateCourseRaw> all) {
  final courseKey2Entity = <String, Course>{};
  var counter = 0;
  for (final raw in all) {
    final courseKey = counter++;
    final weekIndices = parseWeekText2RangedNumbers(
      mapChinesePunctuations(raw.weekText),
      allSuffix: "周",
      oddSuffix: "周(单)",
      evenSuffix: "周(双)",
    );
    final dayIndex = weekday2Index[raw.weekDayText];
    assert(dayIndex != null && 0 <= dayIndex && dayIndex < 7, "dayIndex isn't in range [0,6] but $dayIndex");
    if (dayIndex == null || !(0 <= dayIndex && dayIndex < 7)) continue;
    final timeslots = rangeFromString(raw.timeslotsText, number2index: true);
    assert(timeslots.start <= timeslots.end, "${timeslots.start} > ${timeslots.end} actually. ${raw.courseName}");
    final course = Course(
      courseKey: courseKey,
      courseName: mapChinesePunctuations(raw.courseName).trim(),
      courseCode: raw.courseCode.trim(),
      classCode: raw.classCode.trim(),
      place: reformatPlace(mapChinesePunctuations(raw.place)),
      weekIndices: weekIndices,
      timeslots: timeslots,
      courseCredit: double.tryParse(raw.courseCredit) ?? 0.0,
      dayIndex: dayIndex,
      teachers: raw.teachers.split(","),
    );
    courseKey2Entity["$courseKey"] = course;
  }
  return (
    courses: courseKey2Entity,
    lastCourseKey: counter,
  );
}

Campus? _parseCampus(String campus) {
  if (campus.contains("奉贤")) {
    return Campus.fengxian;
  } else if (campus.contains("徐汇")) {
    return Campus.xuhui;
  }
  return null;
}

Campus? _extractCampusFromCourses(Iterable<UndergraduateCourseRaw> courses) {
  for (final course in courses) {
    final campus = _parseCampus(course.campus);
    if (campus != null) return campus;
  }
  return null;
}

Timetable parseUndergraduateTimetableFromRaw(
  Map json, {
  required Campus defaultCampus,
}) {
  final List<dynamic> courseList = json['kbList'];
  final Map info = json["xsxx"];
  final String name = info["XM"];
  final String semesterRaw = info["XQM"];
  final String schoolYearRaw = info["XNM"];
  final String studentId = info["XH"];
  final schoolYear = int.parse(schoolYearRaw);
  final semester = Semester.fromUgRegFormField(semesterRaw);
  final rawCourses = courseList.map((e) => UndergraduateCourseRaw.fromJson(e)).toList();
  final (:courses, :lastCourseKey) = _parseUndergraduateTimetableFromCourseRaw(
    rawCourses,
  );
  return Timetable(
    uuid: const Uuid().v4(),
    courses: courses,
    studentId: studentId,
    schoolCode: SchoolCode.sit,
    studentType: StudentType.undergraduate,
    lastCourseKey: lastCourseKey,
    signature: name,
    name: i18n.import.defaultName(semester.l10n(), schoolYear.toString(), (schoolYear + 1).toString()),
    startDate: estimateStartDate(schoolYear, semester),
    createdTime: DateTime.now(),
    campus: _extractCampusFromCourses(rawCourses) ?? defaultCampus,
    schoolYear: schoolYear,
    semester: semester,
    lastModified: DateTime.now(),
  );
}
