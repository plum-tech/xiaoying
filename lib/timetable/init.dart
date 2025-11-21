import 'storage/timetable.dart';

class TimetableInit {
  static late TimetableStorage storage;

  static void initStorage() {
    storage = TimetableStorage();
  }
}
