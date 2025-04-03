import 'package:collection/collection.dart';
import 'package:mimir/school/entity/school.dart';

import 'entity/result.ug.dart';
import 'init.dart';

class XExamResult {
  static Future<({Map<SemesterInfo, List<ExamResultUg>> semester2Results, List<ExamResultUg> all})>
      fetchAndCacheExamResultUgEachSemester({
    void Function(double progress)? onProgress,
  }) async {
    final all = await ExamResultInit.ugService.fetchResultList(
      SemesterInfo.all,
      onProgress: onProgress,
    );
    final semester2Results = all.groupListsBy((result) => result.semesterInfo);
    final storage = ExamResultInit.ugStorage;
    await storage.setResultList(SemesterInfo.all, all);
    for (final MapEntry(key: semester, value: list) in semester2Results.entries) {
      await storage.setResultList(semester, list);
    }
    return (semester2Results: semester2Results, all: all);
  }
}
