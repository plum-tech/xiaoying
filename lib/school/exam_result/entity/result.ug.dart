import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/storage/hive/type_id.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/utils/date.dart';

part 'result.ug.g.dart';

String _parseCourseName(dynamic courseName) {
  return mapChinesePunctuations(courseName.toString());
}

Semester _formFieldToSemester(String s) {
  Map<String, Semester> semester = {
    '': Semester.all,
    '3': Semester.term1,
    '12': Semester.term2,
  };
  return semester[s]!;
}

SchoolYear _formFieldToSchoolYear(String s) {
  return int.parse(s.split('-')[0]);
}

String _schoolYearToFormField(SchoolYear year) {
  return '$year-${year + 1}';
}

final _timeFormat = DateFormat("yyyy-MM-dd hh:mm:ss");

DateTime? _parseTime(dynamic time) {
  if (time == null) return null;
  return _timeFormat.parse(time.toString());
}

List<String> _parseTeachers(String? text) {
  if (text == null) return const [];
  if (text == "无") return const [];
  return text.split(";");
}

@HiveType(typeId: CacheHiveType.examResultUgExamType)
enum UgExamType {
  /// 正常考试
  @HiveField(0)
  normal,

  /// 补考一
  @HiveField(1)
  resit,

  /// 重修
  @HiveField(2)
  retake;

  String l10n() => "examResult.examType.$name".tr();

  static UgExamType parse(String type) {
    if (type == "正常考试") return normal;
    if (type == "重修") return retake;
    if (type.contains("补考")) return resit;
    // fallback to normal
    return normal;
  }
}

@JsonSerializable()
@HiveType(typeId: CacheHiveType.examResultUg)
@CopyWith(skipFields: true)
class ExamResultUg {
  /// If the teacher of class hasn't been evaluated, the score is NaN.
  @JsonKey(name: 'cj', fromJson: double.tryParse)
  @HiveField(0)
  final double? score;

  /// 课程
  @JsonKey(name: 'kcmc', fromJson: _parseCourseName)
  @HiveField(1)
  final String courseName;

  /// 课程代码
  @JsonKey(name: 'kch')
  @HiveField(2)
  final String courseCode;

  /// 班级（正方内部使用）
  @JsonKey(name: 'jxb_id')
  @HiveField(3)
  final String innerClassId;

  /// 班级ID（数字）
  @JsonKey(name: 'jxbmc', defaultValue: "")
  @HiveField(4)
  final String classCode;

  /// 学年
  @JsonKey(name: 'xnmmc', fromJson: _formFieldToSchoolYear, toJson: _schoolYearToFormField)
  @HiveField(5)
  final SchoolYear year;

  /// 学期
  @JsonKey(name: 'xqm', fromJson: _formFieldToSemester)
  @HiveField(6)
  final Semester semester;

  /// 学分
  @JsonKey(name: 'xf', fromJson: double.parse)
  @HiveField(7)
  final double credit;

  @JsonKey(name: "tjsj", fromJson: _parseTime, includeToJson: false)
  @HiveField(8)
  final DateTime? time;

  @JsonKey(name: "kclbmc", fromJson: CourseCat.parse)
  @HiveField(9)
  final CourseCat courseCat;

  @JsonKey(name: "jsxm", fromJson: _parseTeachers)
  @HiveField(10)
  final List<String> teachers;

  @JsonKey(name: "ksxz", fromJson: UgExamType.parse)
  @HiveField(11)
  final UgExamType examType;

  @JsonKey(includeToJson: false, includeFromJson: false)
  @HiveField(12)
  final List<ExamResultItem> items;

  const ExamResultUg({
    required this.score,
    required this.courseName,
    required this.courseCode,
    required this.innerClassId,
    required this.year,
    required this.semester,
    required this.credit,
    required this.classCode,
    required this.time,
    required this.courseCat,
    required this.examType,
    required this.teachers,
    this.items = const [],
  });

  bool get passed {
    final score = this.score;
    return score != null ? score >= 60.0 : false;
  }

  bool get isPreparatory => courseCode.startsWith("YK");

  SemesterInfo get semesterInfo => SemesterInfo(year: year, semester: semester);

  factory ExamResultUg.fromJson(Map<String, dynamic> json) => _$ExamResultUgFromJson(json);

  @override
  String toString() {
    return {
      "score": "$score",
      "courseName": courseName,
      "courseId": courseCode,
      "innerClassId": innerClassId,
      "dynClassId": classCode,
      "schoolYear": "$year",
      "semester": "$semester",
      "credit": "$credit",
      "time": time,
      "items": "$items",
    }.toString();
  }

  static int compareByTime(ExamResultUg a, ExamResultUg b) {
    return dateTimeComparator(a.time, b.time);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExamResultUg &&
        runtimeType == other.runtimeType &&
        score == other.score &&
        courseName == other.courseName &&
        courseCode == other.courseCode &&
        innerClassId == other.innerClassId &&
        year == other.year &&
        semester == other.semester &&
        credit == other.credit &&
        classCode == other.classCode &&
        time == other.time &&
        courseCat == other.courseCat &&
        examType == other.examType &&
        teachers.equals(other.teachers) &&
        items.equals(other.items);
  }

  @override
  int get hashCode => Object.hashAll([
        score,
        courseName,
        courseCode,
        innerClassId,
        year,
        semester,
        credit,
        classCode,
        time,
        courseCat,
        examType,
        Object.hashAll(teachers),
        Object.hashAll(items),
      ]);
}

@HiveType(typeId: CacheHiveType.examResultUgItem)
class ExamResultItem {
  /// 成绩名称
  @HiveField(0)
  final String scoreType;

  /// 占总成绩百分比
  @HiveField(1)
  final String percentage;

  /// 成绩数值
  @HiveField(3)
  final double? score;

  const ExamResultItem({
    required this.scoreType,
    required this.percentage,
    this.score,
  });

  @override
  String toString() {
    return {
      "scoreType": scoreType,
      "percentage": percentage,
      "score": score,
    }.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExamResultItem &&
        runtimeType == other.runtimeType &&
        scoreType == other.scoreType &&
        score == other.score &&
        percentage == other.percentage;
  }

  @override
  int get hashCode => Object.hash(scoreType, score, percentage);
}
