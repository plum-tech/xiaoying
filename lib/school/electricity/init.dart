import 'service/electricity.dart';
import 'storage/electricity.dart';

class ElectricityBalanceInit {
  static late ElectricityStorage storage;
  static late ElectricityService service;

  static void init() {
    service = const ElectricityService();
  }

  static void initStorage() {
    storage = ElectricityStorage();
  }
}
