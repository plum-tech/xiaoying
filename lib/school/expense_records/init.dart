import 'service/fetch.dart';
import 'storage/local.dart';

class ExpenseRecordsInit {
  static late ExpenseService service;
  static late ExpenseStorage storage;

  static void init() {
    service = const ExpenseService();
  }

  static void initStorage() {
    storage = ExpenseStorage();
  }
}
