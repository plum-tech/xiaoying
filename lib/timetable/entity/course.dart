import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable(createToJson: false)
class UndergraduateCourseRaw {
  /// 课程名称
  @JsonKey(name: 'kcmc')
  final String courseName;

  /// 星期
  @JsonKey(name: 'xqjmc')
  final String weekDayText;

  /// 节次
  @JsonKey(name: 'jcs')
  final String timeslotsText;

  /// 周次
  @JsonKey(name: 'zcd')
  final String weekText;

  /// 教室
  @JsonKey(name: 'cdmc')
  final String place;

  /// 教师
  @JsonKey(name: 'xm', defaultValue: "")
  final String teachers;

  /// 校区
  @JsonKey(name: 'xqmc')
  final String campus;

  /// 学分
  @JsonKey(name: 'xf')
  final String courseCredit;

  /// 学时
  @JsonKey(name: 'zxs')
  final String creditHour;

  /// 教学班
  @JsonKey(name: 'jxbmc')
  final String classCode;

  /// 课程代码
  @JsonKey(name: 'kch')
  final String courseCode;

  factory UndergraduateCourseRaw.fromJson(Map<String, dynamic> json) => _$UndergraduateCourseRawFromJson(json);

  const UndergraduateCourseRaw({
    required this.courseName,
    required this.weekDayText,
    required this.timeslotsText,
    required this.weekText,
    required this.place,
    required this.teachers,
    required this.campus,
    required this.courseCredit,
    required this.creditHour,
    required this.classCode,
    required this.courseCode,
  });
}

class PostgraduateCourseRaw {
  /// 课程名称
  late String courseName;

  /// 星期
  late String weekDayText;

  /// 节次
  late String timeslotsText;

  /// 周次
  late String weekText;

  /// 教室
  late String place;

  /// 教师
  late String teachers;

  /// 学分
  late String courseCredit;

  /// 学时
  late String creditHour;

  /// 教学班
  late String classCode;

  /// 课程代码
  late String courseCode;

  PostgraduateCourseRaw({
    required this.courseName,
    required this.weekDayText,
    required this.timeslotsText,
    required this.weekText,
    required this.place,
    required this.teachers,
    required this.courseCredit,
    required this.creditHour,
    required this.classCode,
    required this.courseCode,
  });
}
