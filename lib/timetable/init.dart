import 'service/school.dart';
import 'storage/timetable.dart';

class TimetableInit {
  static late TimetableService service;
  static late TimetableStorage storage;

  static void init() {
    service = const TimetableService();
  }

  static void initStorage() {
    storage = TimetableStorage();
  }
}
