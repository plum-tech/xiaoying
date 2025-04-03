import 'package:collection/collection.dart';
import 'package:mimir/school/entity/school.dart';

import 'entity/gpa.dart';
import 'entity/result.ug.dart';

({double gpa, double credit}) calcGPA(Iterable<({double score, double credit})> resultList) {
  double totalCredits = 0.0;
  double sum = 0.0;

  for (final s in resultList) {
    final score = s.score;
    assert(score >= 0, "Exam score should be >= 0");
    totalCredits += s.credit;
    sum += s.credit * score;
  }
  final res = sum / totalCredits / 10.0 - 5.0;
  return (gpa: res.isNaN ? 0 : res, credit: totalCredits);
}

List<ExamResultUg> filterGpaAvailableResult(List<ExamResultUg> list) {
  return list.where((result) => result.score != null && !result.isPreparatory).toList();
}

List<({SemesterInfo semester, List<ExamResultUg> results})> groupExamResultList(List<ExamResultUg> list) {
  final semester2Result = list.groupListsBy((result) => result.semesterInfo);
  final groups = semester2Result.entries.map((entry) => (semester: entry.key, results: entry.value)).toList();
  groups.sortBy((group) => group.semester);
  return groups;
}

List<ExamResultGpaItem> extractExamResultGpaItems(List<ExamResultUg> list) {
  final groupByExamType = list.groupListsBy((result) => result.examType);
  final normal = groupByExamType[UgExamType.normal] ?? [];
  final resit = groupByExamType[UgExamType.resit] ?? [];
  final retake = groupByExamType[UgExamType.retake] ?? [];

  final res = <ExamResultGpaItem>[];
  var index = 0;
  for (final exam in normal) {
    final relatedResit = resit.where((e) => e.courseCode == exam.courseCode).toList();
    final relatedRetake = retake.where((e) => e.courseCode == exam.courseCode).toList();
    res.add(ExamResultGpaItem(
      index: index,
      initial: exam,
      resit: relatedResit,
      retake: relatedRetake,
    ));
    index++;
  }
  return res;
}

List<({SemesterInfo semester, List<ExamResultGpaItem> items})> groupExamResultGpaItems(List<ExamResultGpaItem> list) {
  final semester2Result = list.groupListsBy((result) => result.semesterInfo);
  final groups = semester2Result.entries.map((entry) => (semester: entry.key, items: entry.value)).toList();
  groups.sortBy((group) => group.semester);
  return groups;
}
