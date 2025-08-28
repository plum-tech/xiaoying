import 'service/result.ug.dart';
import 'storage/result.ug.dart';

class ExamResultInit {
  static late ExamResultUgService ugService;
  static late ExamResultUgStorage ugStorage;

  static void init() {
    ugService = const ExamResultUgService();
  }

  static void initStorage() {
    ugStorage = ExamResultUgStorage();
  }
}
