import 'service/result.pg.dart';
import 'service/result.ug.dart';
import 'storage/result.pg.dart';
import 'storage/result.ug.dart';

class ExamResultInit {
  static late ExamResultUgService ugService;
  static late ExamResultPgService pgService;
  static late ExamResultUgStorage ugStorage;
  static late ExamResultPgStorage pgStorage;

  static void init() {
    ugService = const ExamResultUgService();
    pgService = const ExamResultPgService();
  }

  static void initStorage() {
    ugStorage = ExamResultUgStorage();
    pgStorage = ExamResultPgStorage();
  }
}
