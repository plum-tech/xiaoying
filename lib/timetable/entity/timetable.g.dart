// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TimetableCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Timetable(...).copyWith(id: 12, name: "My name")
  /// ````
  Timetable call({
    String uuid,
    Map<String, Course> courses,
    int lastCourseKey,
    String name,
    DateTime startDate,
    Campus campus,
    int schoolYear,
    Semester semester,
    DateTime lastModified,
    DateTime createdTime,
    String studentId,
    StudentType studentType,
    String signature,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTimetable.copyWith(...)`.
class _$TimetableCWProxyImpl implements _$TimetableCWProxy {
  const _$TimetableCWProxyImpl(this._value);

  final Timetable _value;

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Timetable(...).copyWith(id: 12, name: "My name")
  /// ````
  Timetable call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? courses = const $CopyWithPlaceholder(),
    Object? lastCourseKey = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? startDate = const $CopyWithPlaceholder(),
    Object? campus = const $CopyWithPlaceholder(),
    Object? schoolYear = const $CopyWithPlaceholder(),
    Object? semester = const $CopyWithPlaceholder(),
    Object? lastModified = const $CopyWithPlaceholder(),
    Object? createdTime = const $CopyWithPlaceholder(),
    Object? studentId = const $CopyWithPlaceholder(),
    Object? studentType = const $CopyWithPlaceholder(),
    Object? signature = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return Timetable(
      uuid: uuid == const $CopyWithPlaceholder()
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      courses: courses == const $CopyWithPlaceholder()
          ? _value.courses
          // ignore: cast_nullable_to_non_nullable
          : courses as Map<String, Course>,
      lastCourseKey: lastCourseKey == const $CopyWithPlaceholder()
          ? _value.lastCourseKey
          // ignore: cast_nullable_to_non_nullable
          : lastCourseKey as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      startDate: startDate == const $CopyWithPlaceholder()
          ? _value.startDate
          // ignore: cast_nullable_to_non_nullable
          : startDate as DateTime,
      campus: campus == const $CopyWithPlaceholder()
          ? _value.campus
          // ignore: cast_nullable_to_non_nullable
          : campus as Campus,
      schoolYear: schoolYear == const $CopyWithPlaceholder()
          ? _value.schoolYear
          // ignore: cast_nullable_to_non_nullable
          : schoolYear as int,
      semester: semester == const $CopyWithPlaceholder()
          ? _value.semester
          // ignore: cast_nullable_to_non_nullable
          : semester as Semester,
      lastModified: lastModified == const $CopyWithPlaceholder()
          ? _value.lastModified
          // ignore: cast_nullable_to_non_nullable
          : lastModified as DateTime,
      createdTime: createdTime == const $CopyWithPlaceholder()
          ? _value.createdTime
          // ignore: cast_nullable_to_non_nullable
          : createdTime as DateTime,
      studentId: studentId == const $CopyWithPlaceholder()
          ? _value.studentId
          // ignore: cast_nullable_to_non_nullable
          : studentId as String,
      studentType: studentType == const $CopyWithPlaceholder()
          ? _value.studentType
          // ignore: cast_nullable_to_non_nullable
          : studentType as StudentType,
      signature: signature == const $CopyWithPlaceholder()
          ? _value.signature
          // ignore: cast_nullable_to_non_nullable
          : signature as String,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $TimetableCopyWith on Timetable {
  /// Returns a callable class that can be used as follows: `instanceOfTimetable.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TimetableCWProxy get copyWith => _$TimetableCWProxyImpl(this);
}

abstract class _$CourseCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Course(...).copyWith(id: 12, name: "My name")
  /// ````
  Course call({
    int courseKey,
    String courseName,
    String courseCode,
    String classCode,
    String place,
    TimetableWeekIndices weekIndices,
    ({int end, int start}) timeslots,
    double courseCredit,
    int dayIndex,
    List<String> teachers,
    bool hidden,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCourse.copyWith(...)`.
class _$CourseCWProxyImpl implements _$CourseCWProxy {
  const _$CourseCWProxyImpl(this._value);

  final Course _value;

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Course(...).copyWith(id: 12, name: "My name")
  /// ````
  Course call({
    Object? courseKey = const $CopyWithPlaceholder(),
    Object? courseName = const $CopyWithPlaceholder(),
    Object? courseCode = const $CopyWithPlaceholder(),
    Object? classCode = const $CopyWithPlaceholder(),
    Object? place = const $CopyWithPlaceholder(),
    Object? weekIndices = const $CopyWithPlaceholder(),
    Object? timeslots = const $CopyWithPlaceholder(),
    Object? courseCredit = const $CopyWithPlaceholder(),
    Object? dayIndex = const $CopyWithPlaceholder(),
    Object? teachers = const $CopyWithPlaceholder(),
    Object? hidden = const $CopyWithPlaceholder(),
  }) {
    return Course(
      courseKey: courseKey == const $CopyWithPlaceholder()
          ? _value.courseKey
          // ignore: cast_nullable_to_non_nullable
          : courseKey as int,
      courseName: courseName == const $CopyWithPlaceholder()
          ? _value.courseName
          // ignore: cast_nullable_to_non_nullable
          : courseName as String,
      courseCode: courseCode == const $CopyWithPlaceholder()
          ? _value.courseCode
          // ignore: cast_nullable_to_non_nullable
          : courseCode as String,
      classCode: classCode == const $CopyWithPlaceholder()
          ? _value.classCode
          // ignore: cast_nullable_to_non_nullable
          : classCode as String,
      place: place == const $CopyWithPlaceholder()
          ? _value.place
          // ignore: cast_nullable_to_non_nullable
          : place as String,
      weekIndices: weekIndices == const $CopyWithPlaceholder()
          ? _value.weekIndices
          // ignore: cast_nullable_to_non_nullable
          : weekIndices as TimetableWeekIndices,
      timeslots: timeslots == const $CopyWithPlaceholder()
          ? _value.timeslots
          // ignore: cast_nullable_to_non_nullable
          : timeslots as ({int end, int start}),
      courseCredit: courseCredit == const $CopyWithPlaceholder()
          ? _value.courseCredit
          // ignore: cast_nullable_to_non_nullable
          : courseCredit as double,
      dayIndex: dayIndex == const $CopyWithPlaceholder()
          ? _value.dayIndex
          // ignore: cast_nullable_to_non_nullable
          : dayIndex as int,
      teachers: teachers == const $CopyWithPlaceholder()
          ? _value.teachers
          // ignore: cast_nullable_to_non_nullable
          : teachers as List<String>,
      hidden: hidden == const $CopyWithPlaceholder()
          ? _value.hidden
          // ignore: cast_nullable_to_non_nullable
          : hidden as bool,
    );
  }
}

extension $CourseCopyWith on Course {
  /// Returns a callable class that can be used as follows: `instanceOfCourse.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$CourseCWProxy get copyWith => _$CourseCWProxyImpl(this);
}

abstract class _$TimetableWeekIndexCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableWeekIndex(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableWeekIndex call({
    TimetableWeekIndexType type,
    ({int end, int start}) range,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTimetableWeekIndex.copyWith(...)`.
class _$TimetableWeekIndexCWProxyImpl implements _$TimetableWeekIndexCWProxy {
  const _$TimetableWeekIndexCWProxyImpl(this._value);

  final TimetableWeekIndex _value;

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableWeekIndex(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableWeekIndex call({
    Object? type = const $CopyWithPlaceholder(),
    Object? range = const $CopyWithPlaceholder(),
  }) {
    return TimetableWeekIndex(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as TimetableWeekIndexType,
      range: range == const $CopyWithPlaceholder()
          ? _value.range
          // ignore: cast_nullable_to_non_nullable
          : range as ({int end, int start}),
    );
  }
}

extension $TimetableWeekIndexCopyWith on TimetableWeekIndex {
  /// Returns a callable class that can be used as follows: `instanceOfTimetableWeekIndex.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TimetableWeekIndexCWProxy get copyWith =>
      _$TimetableWeekIndexCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timetable _$TimetableFromJson(Map<String, dynamic> json) => Timetable(
  uuid: json['uuid'] as String? ?? _kUUid(),
  courses: (json['courses'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, Course.fromJson(e as Map<String, dynamic>)),
  ),
  lastCourseKey: (json['lastCourseKey'] as num).toInt(),
  name: _parseName(json['name'] as String),
  startDate: DateTime.parse(json['startDate'] as String),
  campus:
      $enumDecodeNullable(
        _$CampusEnumMap,
        json['campus'],
        unknownValue: Campus.defaultCampus,
      ) ??
      _defaultCampus(),
  schoolYear: (json['schoolYear'] as num).toInt(),
  semester: $enumDecode(_$SemesterEnumMap, json['semester']),
  lastModified: json['lastModified'] == null
      ? _kNow()
      : DateTime.parse(json['lastModified'] as String),
  createdTime: json['createdTime'] == null
      ? _kNow()
      : DateTime.parse(json['createdTime'] as String),
  studentId: json['studentId'] as String? ?? _defaultStudentId(),
  studentType:
      $enumDecodeNullable(_$StudentTypeEnumMap, json['studentType']) ??
      _kStudentType(),
  signature: json['signature'] as String? ?? "",
  version: (json['version'] as num?)?.toInt() ?? 2,
);

Map<String, dynamic> _$TimetableToJson(Timetable instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'startDate': instance.startDate.toIso8601String(),
  'campus': _$CampusEnumMap[instance.campus]!,
  'schoolYear': instance.schoolYear,
  'semester': _$SemesterEnumMap[instance.semester]!,
  'studentType': _$StudentTypeEnumMap[instance.studentType]!,
  'lastCourseKey': instance.lastCourseKey,
  'signature': instance.signature,
  'studentId': instance.studentId,
  'courses': instance.courses,
  'lastModified': instance.lastModified.toIso8601String(),
  'createdTime': instance.createdTime.toIso8601String(),
  'version': instance.version,
};

const _$CampusEnumMap = {Campus.defaultCampus: 'defaultCampus'};

const _$SemesterEnumMap = {
  Semester.all: 'all',
  Semester.term1: 'term1',
  Semester.term2: 'term2',
};

const _$StudentTypeEnumMap = {
  StudentType.undergraduate: 'undergraduate',
  StudentType.postgraduate: 'postgraduate',
};

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
  courseKey: (json['courseKey'] as num).toInt(),
  courseName: json['courseName'] as String,
  courseCode: json['courseCode'] as String,
  classCode: json['classCode'] as String,
  place: json['place'] as String,
  weekIndices: TimetableWeekIndices.fromJson(json['weekIndices']),
  timeslots: _$recordConvert(
    json['timeslots'],
    ($jsonValue) => (
      end: ($jsonValue['end'] as num).toInt(),
      start: ($jsonValue['start'] as num).toInt(),
    ),
  ),
  courseCredit: (json['courseCredit'] as num).toDouble(),
  dayIndex: (json['dayIndex'] as num).toInt(),
  teachers: (json['teachers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  hidden: json['hidden'] as bool? ?? false,
);

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
  'courseKey': instance.courseKey,
  'courseName': instance.courseName,
  'courseCode': instance.courseCode,
  'classCode': instance.classCode,
  'place': instance.place,
  'weekIndices': instance.weekIndices,
  'timeslots': <String, dynamic>{
    'end': instance.timeslots.end,
    'start': instance.timeslots.start,
  },
  'courseCredit': instance.courseCredit,
  'dayIndex': instance.dayIndex,
  'teachers': instance.teachers,
  'hidden': instance.hidden,
};

$Rec _$recordConvert<$Rec>(Object? value, $Rec Function(Map) convert) =>
    convert(value as Map<String, dynamic>);

TimetableWeekIndex _$TimetableWeekIndexFromJson(Map<String, dynamic> json) =>
    TimetableWeekIndex(
      type: $enumDecode(_$TimetableWeekIndexTypeEnumMap, json['type']),
      range: _$recordConvert(
        json['range'],
        ($jsonValue) => (
          end: ($jsonValue['end'] as num).toInt(),
          start: ($jsonValue['start'] as num).toInt(),
        ),
      ),
    );

Map<String, dynamic> _$TimetableWeekIndexToJson(TimetableWeekIndex instance) =>
    <String, dynamic>{
      'type': _$TimetableWeekIndexTypeEnumMap[instance.type]!,
      'range': <String, dynamic>{
        'end': instance.range.end,
        'start': instance.range.start,
      },
    };

const _$TimetableWeekIndexTypeEnumMap = {
  TimetableWeekIndexType.all: 'all',
  TimetableWeekIndexType.odd: 'odd',
  TimetableWeekIndexType.even: 'even',
};
