import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/utils/error.dart';
import 'package:mimir/utils/permission.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../entity/timetable.dart';
import '../i18n.dart';
import '../utils.dart';
import 'parse.ug.dart';

Future<Timetable?> _readTimetableFromFile(String path) async {
  final file = File(path);
  final bytes = await file.readAsBytes();
  return readTimetableFromBytes(bytes);
}

Future<Timetable?> readTimetableFromBytes(Uint8List bytes) async {
  // timetable file should be encoding in utf-8.
  final content = const Utf8Decoder().convert(bytes.toList());
  final json = jsonDecode(content);
  try {
    final timetable = Timetable.fromJson(json);
    return timetable;
  } catch (error, stackTrace) {
    debugPrintError(error, stackTrace);
    // try parsing the file as timetable raw
    return parseUndergraduateTimetableFromRaw(
      json,
      defaultCampus: Campus.defaultCampus,
    );
  }
}

Future<Timetable?> readTimetableFromFileWithPrompt(
  BuildContext context,
  String path,
) async {
  return readTimetableWithPrompt(
    context,
    get: () => _readTimetableFromFile(path),
  );
}

Future<Timetable?> readSampleTimetableWithPrompt(
  BuildContext context, {
  SemesterInfo? semesterInfo,
}) {
  return readTimetableWithPrompt(
    context,
    get: () async => buildSampleTimetable(semesterInfo: semesterInfo),
  );
}

Future<Timetable?> readTimetableWithPrompt(
  BuildContext context, {
  required Future<Timetable?> Function() get,
}) async {
  try {
    final timetable = await get();
    return timetable;
  } catch (error, stackTrace) {
    debugPrintError(error, stackTrace);
    if (!context.mounted) return null;
    if (error is PlatformException) {
      await showPermissionDeniedDialog(context, Permission.storage);
    } else if (error is FileSystemException) {
      await context.showTip(
        title: i18n.import.formatError,
        desc: error.osError?.message ?? error.message,
        primary: i18n.ok,
      );
    } else {
      await context.showTip(
        title: i18n.import.formatError,
        desc: i18n.import.formatErrorDesc,
        primary: i18n.ok,
      );
    }
    return null;
  }
}

Timetable buildSampleTimetable({SemesterInfo? semesterInfo}) {
  final now = DateTime.now();
  final info = semesterInfo ?? estimateSemesterInfo(now);
  final schoolYear = info.year ?? estimateSchoolYear(now);
  final semester = info.semester == Semester.all
      ? estimateSemester(now)
      : info.semester;
  final startDate = info.exactlyOne
      ? estimateStartDate(schoolYear, semester)
      : _startOfCurrentWeek(now);
  final createdAt = DateTime(
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute,
  );
  final courses = _buildSampleCourses();
  return Timetable(
    uuid: const Uuid().v4(),
    name: i18n.import.sampleName,
    startDate: startDate,
    campus: Settings.campus,
    schoolYear: schoolYear,
    semester: semester,
    studentType: StudentType.undergraduate,
    lastCourseKey: courses.length,
    signature: Settings.lastSignature ?? "",
    studentId: "",
    courses: {for (final course in courses) "${course.courseKey}": course},
    lastModified: createdAt,
    createdTime: createdAt,
  );
}

DateTime _startOfCurrentWeek(DateTime date) {
  final monday = date.subtract(Duration(days: date.weekday - DateTime.monday));
  return DateTime(monday.year, monday.month, monday.day);
}

List<Course> _buildSampleCourses() {
  return const [
    Course(
      courseKey: 0,
      courseName: "高等数学",
      courseCode: "MATH101",
      classCode: "A01",
      place: "一教A101",
      weekIndices: TimetableWeekIndices([
        TimetableWeekIndex.all((start: 0, end: 15)),
      ]),
      timeslots: (start: 0, end: 1),
      courseCredit: 4,
      dayIndex: 0,
      teachers: ["王老师"],
    ),
    Course(
      courseKey: 1,
      courseName: "程序设计基础",
      courseCode: "CS102",
      classCode: "B02",
      place: "二教B203",
      weekIndices: TimetableWeekIndices([
        TimetableWeekIndex.all((start: 0, end: 15)),
      ]),
      timeslots: (start: 2, end: 3),
      courseCredit: 3,
      dayIndex: 1,
      teachers: ["李老师"],
    ),
    Course(
      courseKey: 2,
      courseName: "大学英语",
      courseCode: "ENG103",
      classCode: "C03",
      place: "外语楼302",
      weekIndices: TimetableWeekIndices([
        TimetableWeekIndex.even((start: 0, end: 15)),
      ]),
      timeslots: (start: 4, end: 5),
      courseCredit: 2,
      dayIndex: 2,
      teachers: ["Chen"],
    ),
    Course(
      courseKey: 3,
      courseName: "体育",
      courseCode: "PE104",
      classCode: "D04",
      place: "体育馆",
      weekIndices: TimetableWeekIndices([
        TimetableWeekIndex.odd((start: 0, end: 15)),
      ]),
      timeslots: (start: 6, end: 7),
      courseCredit: 1,
      dayIndex: 4,
      teachers: ["周老师"],
    ),
  ];
}
