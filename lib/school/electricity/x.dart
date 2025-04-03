import 'package:mimir/school/electricity/init.dart';
import 'package:mimir/settings/settings.dart';

class XElectricity {
  static void addSearchHistory(String room) {
    final storage = ElectricityBalanceInit.storage;
    final searchHistory = storage.searchHistory ?? <String>[];
    if (searchHistory.any((e) => e == room)) return;
    searchHistory.insert(0, room);
    storage.searchHistory = searchHistory;
  }

  static void setSelectedRoom(String room) {
    Settings.school.electricity.selectedRoom = room;
    addSearchHistory(room);
    ElectricityBalanceInit.storage.lastUpdateTime = null;
  }

  static void clearSelectedRoom() {
    Settings.school.electricity.selectedRoom = null;
    ElectricityBalanceInit.storage.lastUpdateTime = null;
    ElectricityBalanceInit.storage.lastBalance = null;
  }

  static Future<void> refresh({required String selectedRoom}) async {
    final lastBalance = await ElectricityBalanceInit.service.getBalance(selectedRoom);
    if (lastBalance.roomNumber == selectedRoom) {
      ElectricityBalanceInit.storage.lastBalance = lastBalance;
      ElectricityBalanceInit.storage.lastUpdateTime = DateTime.now();
    }
  }
}
