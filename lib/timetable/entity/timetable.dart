import 'dart:math';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:mimir/backend/entity/user.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/entity/uuid.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/entity/timetable.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/timetable/utils.dart';
import 'package:statistics/statistics.dart';
import 'package:uuid/uuid.dart';

part 'timetable.g.dart';

DateTime _kNow() => DateTime.now();

SchoolCode _kSchoolCode() => SchoolCode.sit;

StudentType _kStudentType() => switch (CredentialsInit.storage.oa.userType) {
      OaUserType.undergraduate => StudentType.undergraduate,
      OaUserType.postgraduate => StudentType.postgraduate,
      _ => StudentType.undergraduate,
    };

Campus _defaultCampus() {
  return Settings.campus;
}

String _defaultStudentId() {
  return CredentialsInit.storage.oa.credentials?.account ?? "";
}

String _parseName(String name) {
  return name.substring(0, min(Timetable.maxNameLength, name.length)).replaceAll('\n', " ");
}

String _kUUid() => const Uuid().v4();

@JsonSerializable()
@CopyWith(skipFields: true)
@immutable
class Timetable implements WithUuid {
  static int maxNameLength = 50;
  @override
  @JsonKey(defaultValue: _kUUid)
  final String uuid;
  @JsonKey(fromJson: _parseName)
  final String name;
  @JsonKey()
  final DateTime startDate;
  @JsonKey(unknownEnumValue: Campus.fengxian, defaultValue: _defaultCampus)
  final Campus campus;
  @JsonKey()
  final int schoolYear;
  @JsonKey()
  final Semester semester;
  @JsonKey(defaultValue: _kSchoolCode)
  final SchoolCode schoolCode;
  @JsonKey(defaultValue: _kStudentType)
  final StudentType studentType;
  @JsonKey()
  final int lastCourseKey;
  @JsonKey()
  final String signature;
  @JsonKey(defaultValue: _defaultStudentId)
  final String studentId;

  /// The index is the CourseKey.
  @JsonKey()
  final Map<String, Course> courses;

  @JsonKey(defaultValue: _kNow)
  final DateTime lastModified;

  @JsonKey(defaultValue: _kNow)
  final DateTime createdTime;

  @JsonKey()
  final int version;

  const Timetable({
    required this.uuid,
    required this.courses,
    required this.lastCourseKey,
    required this.name,
    required this.schoolCode,
    required this.startDate,
    required this.campus,
    required this.schoolYear,
    required this.semester,
    required this.lastModified,
    required this.createdTime,
    required this.studentId,
    required this.studentType,
    this.signature = "",
    this.version = 2,
  });

  Timetable markModified() {
    return copyWith(
      lastModified: DateTime.now(),
    );
  }

  DateTime get endDate => startDate.copyWith(day: startDate.day + maxWeekLength * 7);

  bool inRange(DateTime date) {
    return startDate.isBefore(date) && date.isBefore(endDate);
  }

  @override
  String toString() {
    return {
      "uuid": uuid,
      "name": name,
      "startDate": startDate,
      "schoolYear": schoolYear,
      "schoolCode": schoolCode,
      "semester": semester,
      "lastModified": lastModified,
      "createdTime": createdTime,
      "signature": signature,
      "studentId": studentId,
      "studentType": studentType,
    }.toString();
  }

  String toDartCode() {
    return "Timetable("
        'uuid:"$uuid",'
        'name:"$name",'
        'signature:"$signature",'
        'studentId:"$studentId",'
        'schoolCode:"$schoolCode",'
        'studentType:"$studentType",'
        "campus:$campus,"
        'startDate:DateTime.parse("$startDate"),'
        'createdTime:DateTime.parse("$createdTime"),'
        'lastModified:DateTime.parse("$lastModified"),'
        "courses:${courses.map((key, value) => MapEntry('"$key"', value.toDartCode()))},"
        "studentId:$studentId,"
        "studentType:$studentType,"
        "schoolYear:$schoolYear,"
        "semester:$semester,"
        "lastCourseKey:$lastCourseKey,"
        "version:$version,"
        ")";
  }

  @override
  bool operator ==(Object other) {
    return other is Timetable &&
        runtimeType == other.runtimeType &&
        lastCourseKey == other.lastCourseKey &&
        version == other.version &&
        uuid == other.uuid &&
        campus == other.campus &&
        schoolCode == other.schoolCode &&
        schoolYear == other.schoolYear &&
        semester == other.semester &&
        name == other.name &&
        signature == other.signature &&
        startDate == other.startDate &&
        studentId == other.studentId &&
        studentType == other.studentType &&
        lastModified == other.lastModified &&
        createdTime == other.createdTime &&
        courses.equalsKeysValues(courses.keys, other.courses);
  }

  @override
  int get hashCode => Object.hash(
        version,
        uuid,
        name,
        signature,
        lastCourseKey,
        campus,
        schoolYear,
        semester,
        startDate,
        schoolCode,
        lastModified,
        createdTime,
        studentId,
        studentType,
        Object.hashAllUnordered(courses.entries.map((e) => (e.key, e.value))),
      );

  factory Timetable.fromJson(Map<String, dynamic> json) => _$TimetableFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableToJson(this);

  bool isBasicInfoEqualTo(Timetable old) {
    if (lastCourseKey != old.lastCourseKey) return false;
    if (courses.length != old.courses.length) return false;
    if (!courses.keys.toSet().equalsElements(old.courses.keys.toSet())) return false;
    for (final MapEntry(:key, value: course) in courses.entries) {
      final oldCourse = old.courses[key];
      if (oldCourse == null) return false;
      if (!course.isBasicInfoEqualTo(oldCourse)) return false;
    }
    return true;
  }
}

@JsonSerializable()
@CopyWith(skipFields: true)
@immutable
class Course {
  @JsonKey()
  final int courseKey;
  @JsonKey()
  final String courseName;
  @JsonKey()
  final String courseCode;
  @JsonKey()
  final String classCode;

  @JsonKey()
  final String place;

  @JsonKey()
  final TimetableWeekIndices weekIndices;

  /// e.g.: (start:1, end: 3) means `2nd slot to 4th slot`.
  /// Starts with 0
  @JsonKey()
  final ({int start, int end}) timeslots;
  @JsonKey()
  final double courseCredit;

  /// e.g.: `0` means `Monday`
  /// Starts with 0
  @JsonKey()
  final int dayIndex;
  @JsonKey()
  final List<String> teachers;

  @JsonKey()
  final bool hidden;

  const Course({
    required this.courseKey,
    required this.courseName,
    required this.courseCode,
    required this.classCode,
    required this.place,
    required this.weekIndices,
    required this.timeslots,
    required this.courseCredit,
    required this.dayIndex,
    required this.teachers,
    this.hidden = false,
  });

  @override
  String toString() => "#$courseKey($courseName: $place)";

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseToJson(this);

  String toDartCode() {
    return "Course("
        "courseKey:$courseKey,"
        'courseName:"$courseName",'
        'courseCode:"$courseCode",'
        'classCode:"$classCode",'
        'place:"$place",'
        "weekIndices:${weekIndices.toDartCode()},"
        "timeslots:$timeslots,"
        "courseCredit:$courseCredit,"
        "dayIndex:$dayIndex,"
        "teachers:${teachers.map((t) => '"$t"').toList(growable: false)},"
        "hidden:$hidden,"
        ")";
  }

  @override
  bool operator ==(Object other) {
    return other is Course &&
        runtimeType == other.runtimeType &&
        courseKey == other.courseKey &&
        courseName == other.courseName &&
        courseCode == other.courseCode &&
        place == other.place &&
        weekIndices.equalsElements(other.weekIndices) &&
        timeslots == other.timeslots &&
        courseCredit == other.courseCredit &&
        dayIndex == other.dayIndex &&
        teachers.equalsElements(other.teachers) &&
        hidden == other.hidden;
  }

  @override
  int get hashCode => Object.hash(
        courseKey,
        courseName,
        courseCode,
        place,
        weekIndices,
        timeslots,
        courseCredit,
        dayIndex,
        Object.hashAll(teachers),
        hidden,
      );

  bool isBasicInfoEqualTo(Course old) {
    if (courseKey != old.courseKey) return false;
    if (courseCode != old.courseCode) return false;
    if (place != old.place) return false;
    if (!weekIndices.equalsElements(old.weekIndices)) return false;
    if (dayIndex != old.dayIndex) return false;
    if (timeslots != old.timeslots) return false;
    return true;
  }
}

List<ClassTime> buildingTimetableOf(Campus campus, [String? place]) => getTeachingBuildingTimetable(campus, place);

/// Based on [Course.timeslots], compose a full-length class time.
/// Starts with the first part starts.
/// Ends with the last part ends.
ClassTime calcBeginEndTimePoint(({int start, int end}) timeslots, Campus campus, [String? place]) {
  final timetable = buildingTimetableOf(campus, place);
  final (:start, :end) = timeslots;
  return (begin: timetable[start].begin, end: timetable[end].end);
}

List<ClassTime> calcBeginEndTimePointForEachLesson(({int start, int end}) timeslots, Campus campus, [String? place]) {
  final timetable = buildingTimetableOf(campus, place);
  final (:start, :end) = timeslots;
  final result = <ClassTime>[];
  for (var timeslot = start; timeslot <= end; timeslot++) {
    result.add(timetable[timeslot]);
  }
  return result;
}

ClassTime calcBeginEndTimePointOfLesson(int timeslot, Campus campus, [String? place]) {
  final timetable = buildingTimetableOf(campus, place);
  return timetable[timeslot];
}

@JsonEnum()
enum TimetableWeekIndexType {
  all,
  odd,
  even;

  String l10nOf(String start, String end) => "timetable.weekIndexType.of.$name".tr(namedArgs: {
        "start": start,
        "end": end,
      });

  String l10n() => "timetable.weekIndexType.$name".tr();

  static String l10nOfSingle(String index) => "timetable.weekIndexType.of.single".tr(args: [index]);
}

@JsonSerializable()
@CopyWith(skipFields: true)
@immutable
class TimetableWeekIndex {
  @JsonKey()
  final TimetableWeekIndexType type;

  /// Both [start] and [end] are inclusive.
  /// [start] will equal to [end] if it's not ranged.
  @JsonKey()
  final ({int start, int end}) range;

  const TimetableWeekIndex({
    required this.type,
    required this.range,
  });

  const TimetableWeekIndex.all(
    this.range,
  ) : type = TimetableWeekIndexType.all;

  /// [start] will equal to [end].
  const TimetableWeekIndex.single(
    int weekIndex,
  )   : type = TimetableWeekIndexType.all,
        range = (start: weekIndex, end: weekIndex);

  const TimetableWeekIndex.odd(
    this.range,
  ) : type = TimetableWeekIndexType.odd;

  const TimetableWeekIndex.even(
    this.range,
  ) : type = TimetableWeekIndexType.even;

  /// week number start by
  bool match(int weekIndex) {
    return range.start <= weekIndex && weekIndex <= range.end;
  }

  bool get isSingle => range.start == range.end;

  /// convert the index to number.
  /// e.g.: (start: 0, end: 8) => "1–9"
  String l10n() {
    if (isSingle) {
      return TimetableWeekIndexType.l10nOfSingle("${range.start + 1}");
    } else {
      return type.l10nOf("${range.start + 1}", "${range.end + 1}");
    }
  }

  String toDartCode() {
    return "TimetableWeekIndex("
        "type:$type,"
        "range:$range,"
        ")";
  }

  @override
  bool operator ==(Object other) {
    return other is TimetableWeekIndex &&
        runtimeType == other.runtimeType &&
        type == other.type &&
        range == other.range;
  }

  @override
  int get hashCode => Object.hash(type, range);

  factory TimetableWeekIndex.fromJson(Map<String, dynamic> json) => _$TimetableWeekIndexFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableWeekIndexToJson(this);
}

extension type const TimetableWeekIndices(List<TimetableWeekIndex> indices) implements List<TimetableWeekIndex> {
  bool match(int weekIndex) {
    for (final index in indices) {
      if (index.match(weekIndex)) return true;
    }
    return false;
  }

  /// Then the [indices] could be ["a1-5", "s14", "o8-10"]
  /// The return value should be:
  /// - `1-5 周, 14 周, 8-10 单周` in Chinese.
  /// - `1-5 wk, 14 wk, 8-10 odd wk`
  List<String> l10n() {
    return indices.map((index) => index.l10n()).toList();
  }

  /// The result, week index, which starts with 0.
  /// e.g.:
  /// ```dart
  /// TimetableWeekIndices([
  ///  TimetableWeekIndex.all(
  ///    (start: 0, end: 4),
  ///  ),
  ///  TimetableWeekIndex.single(
  ///    13,
  ///  ),
  ///  TimetableWeekIndex.odd(
  ///    (start: 7, end: 9),
  ///  ),
  /// ])
  /// ```
  /// return value is {0,1,2,3,4,13,7,9}.
  Set<int> getWeekIndices() {
    final res = <int>{};
    for (final TimetableWeekIndex(:type, :range) in indices) {
      switch (type) {
        case TimetableWeekIndexType.all:
          for (var i = range.start; i <= range.end; i++) {
            res.add(i);
          }
          break;
        case TimetableWeekIndexType.odd:
          for (var i = range.start; i <= range.end; i += 2) {
            if ((i + 1).isOdd) res.add(i);
          }
          break;
        case TimetableWeekIndexType.even:
          for (var i = range.start; i <= range.end; i++) {
            if ((i + 1).isEven) res.add(i);
          }
          break;
      }
    }
    return res;
  }

  factory TimetableWeekIndices.fromJson(dynamic json) {
    // for backwards support
    if (json is Map) {
      return TimetableWeekIndices(
        (json['indices'] as List<dynamic>).map((e) => TimetableWeekIndex.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } else {
      return TimetableWeekIndices(
        (json as List<dynamic>).map((e) => TimetableWeekIndex.fromJson(e as Map<String, dynamic>)).toList(),
      );
    }
  }

  dynamic toJson() {
    return indices;
  }

  String toDartCode() {
    return "TimetableWeekIndices("
        "${indices.map((i) => i.toDartCode()).toList(growable: false)}"
        ")";
  }
}

/// If [range] is "1-8", the output will be `(start:0, end: 7)`.
/// if [number2index] is true, the [range] will be considered as a number range, which starts with 1 instead of 0.
({int start, int end}) rangeFromString(
  String range, {
  bool number2index = false,
}) {
  if (range.contains("-")) {
// in range of time slots
    final rangeParts = range.split("-");
    final start = int.parse(rangeParts[0]);
    final end = int.parse(rangeParts[1]);
    if (number2index) {
      return (start: start - 1, end: end - 1);
    } else {
      return (start: start, end: end);
    }
  } else {
    final single = int.parse(range);
    if (number2index) {
      return (start: single - 1, end: single - 1);
    } else {
      return (start: single, end: single);
    }
  }
}

String rangeToString(({int start, int end}) range) {
  if (range.start == range.end) {
    return "${range.start}";
  } else {
    return "${range.start}-${range.end}";
  }
}

abstract mixin class CourseCodeIndexer {
  Iterable<Course> get courses;

  final _courseCode2CoursesCache = <String, List<Course>>{};

  List<Course> getCoursesByCourseCode(String courseCode) {
    final found = _courseCode2CoursesCache[courseCode];
    if (found != null) {
      return found;
    } else {
      final res = <Course>[];
      for (final course in courses) {
        if (course.courseCode == courseCode) {
          res.add(course);
        }
      }
      _courseCode2CoursesCache[courseCode] = res;
      return res;
    }
  }
}
