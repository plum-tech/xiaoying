import 'package:collection/collection.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/exam_result/entity/result.ug.dart';

class ExamResultGpaItem {
  // for multi-selection
  final int index;

  /// the first attempt of an exam.
  final ExamResultUg initial;
  final List<ExamResultUg> resit;
  final List<ExamResultUg> retake;

  const ExamResultGpaItem({
    required this.index,
    required this.initial,
    required this.resit,
    required this.retake,
  });

  /// Using the [initial.year]
  SchoolYear get year => initial.year;

  /// Using the [initial.semester]
  Semester get semester => initial.semester;

  /// Using the [initial.semesterInfo]
  SemesterInfo get semesterInfo => initial.semesterInfo;

  CourseCat get courseCat => initial.courseCat;

  /// Even if you retake the course, there will be no change.
  String get courseCode => initial.courseCode;

  String get courseName => initial.courseName;

  double get credit => initial.credit;

  double? get maxScore {
    return [
      ...resit.map((e) => e.score),
      ...retake.map((e) => e.score),
      initial.score,
    ].nonNulls.maxOrNull;
  }

  bool get passed {
    final maxScore = this.maxScore;
    if (maxScore == null) return false;
    return maxScore >= 60.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExamResultGpaItem &&
        runtimeType == other.runtimeType &&
        initial == other.initial &&
        resit.equals(other.resit) &&
        retake.equals(other.retake);
  }

  @override
  int get hashCode => Object.hash(
        initial,
        Object.hashAll(resit),
        Object.hashAll(retake),
      );
}
