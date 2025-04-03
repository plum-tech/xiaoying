import 'package:mimir/utils/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mimir/school/exam_result/entity/result.pg.dart';
import 'package:mimir/storage/hive/init.dart';

class _K {
  static const ns = "/pg";

  static const resultList = "$ns/resultList";
}

class ExamResultPgStorage {
  Box get box => HiveInit.examResult;

  ExamResultPgStorage();

  List<ExamResultPg>? getResultList() => box.safeGet<List>(_K.resultList)?.cast<ExamResultPg>();

  Future<void> setResultList(List<ExamResultPg>? newV) => box.safePut<List>(_K.resultList, newV);

  late final $resultList = box.provider<List<ExamResultPg>>(_K.resultList, get: getResultList);
}
