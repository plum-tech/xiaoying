import 'package:mimir/storage/hive/type_id.dart';

part 'result.pg.g.dart';

class ExamResultPgRaw {
  /// 课程类别
  final String courseType;

  /// 课程编号
  final String courseCode;

  /// 课程名称
  final String courseName;

  /// 学分
  final String credit;

  /// 教师
  final String teacher;

  /// 成绩
  final String score;

  /// 是否及格
  /// eg. "及格"
  final String passStatus;

  /// 考试性质
  /// eg. "期末考试"
  final String examType;

  /// 考试方式
  /// eg. "笔试"
  final String examForm;

  /// 考试时间
  final String examTime;

  /// 备注
  final String notes;

  const ExamResultPgRaw({
    required this.courseType,
    required this.courseCode,
    required this.courseName,
    required this.credit,
    required this.teacher,
    required this.score,
    required this.passStatus,
    required this.examType,
    required this.examForm,
    required this.examTime,
    required this.notes,
  });

  @override
  String toString() {
    return {
      "courseClass": courseType,
      "courseCode": courseCode,
      "courseName": courseName,
      "courseCredit": credit,
      "teacher": teacher,
      "score": score,
      "isPassed": passStatus,
      "examNature": examType,
      "examForm": examForm,
      "examTime": examTime,
    }.toString();
  }

  ExamResultPg parse() {
    return ExamResultPg(
      courseType: courseType,
      courseCode: courseCode,
      courseName: courseName,
      credit: int.parse(credit),
      teacher: teacher,
      score: double.parse(score),
      passed: passStatus == "及格",
      examType: examType,
      form: examForm,
      // currently, time is not given
      time: null,
      notes: notes,
    );
  }

  bool canParse() {
    return double.tryParse(score) != null;
  }
}

@HiveType(typeId: CacheHiveType.examResultPg)
class ExamResultPg {
  @HiveField(0)
  final String courseType;

  @HiveField(1)
  final String courseCode;

  @HiveField(2)
  final String courseName;

  @HiveField(3)
  final int credit;

  @HiveField(4)
  final String teacher;

  /// It's always int. But double is used for most compatibility.
  @HiveField(5)
  final double score;

  @HiveField(6)
  final bool passed;

  @HiveField(7)
  final String examType;

  @HiveField(8)
  final String form;

  @HiveField(9)
  final DateTime? time;

  @HiveField(10)
  final String notes;

  const ExamResultPg({
    required this.courseType,
    required this.courseCode,
    required this.courseName,
    required this.credit,
    required this.teacher,
    required this.score,
    required this.passed,
    required this.examType,
    required this.form,
    required this.time,
    required this.notes,
  });

  @override
  String toString() {
    return {
      "courseClass": courseType,
      "courseCode": courseCode,
      "courseName": courseName,
      "courseCredit": credit,
      "teacher": teacher,
      "score": score,
      "isPassed": passed,
      "examNature": examType,
      "examForm": form,
      "examTime": time,
    }.toString();
  }
}
