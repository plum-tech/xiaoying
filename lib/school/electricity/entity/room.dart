import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/utils/strings.dart';

class DormitoryRoom {
  final int building;
  final int floorWithRoom;
  final int floor;
  final int room;

  const DormitoryRoom({
    required this.building,
    required this.floorWithRoom,
    required this.floor,
    required this.room,
  });

  /// For buildings #1 through #10, their floors are all below 10.
  /// ## examples:
  /// - 101301: building #1, room #301
  /// - 10251524: building #25, room #1524
  factory DormitoryRoom.fromFullString(String full) {
    full = full.removePrefix("10");
    assert(full.length >= 4 && full.length <= 6, '"$full" is too long.');
    if (full.length == 4) {
      // building is in 1 digit, like 1 301
      final buildingRaw = full[0];
      final floorWithRoomNumberRaw = full.substring(1);
      final floorNumberRaw = full.substring(1, 2);
      final roomNumberRaw = full.substring(2);
      return DormitoryRoom(
        building: int.tryParse(buildingRaw) ?? 0,
        floorWithRoom: int.tryParse(floorWithRoomNumberRaw) ?? 0,
        floor: int.tryParse(floorNumberRaw) ?? 0,
        room: int.tryParse(roomNumberRaw) ?? 0,
      );
    } else if (full.length == 5) {
      // building is in 2 digit,like 12 301
      final buildingRaw = full.substring(0, 2);
      final floorWithRoomNumber = full.substring(2);
      final floorNumberRaw = full.substring(2, 3);
      final roomNumberRaw = full.substring(3);
      return DormitoryRoom(
        building: int.tryParse(buildingRaw) ?? 0,
        floorWithRoom: int.tryParse(floorWithRoomNumber) ?? 0,
        floor: int.tryParse(floorNumberRaw) ?? 0,
        room: int.tryParse(roomNumberRaw) ?? 0,
      );
    } else if (full.length == 6) {
      // building is in 2 digit,like 12 1301
      final buildingRaw = full.substring(0, 2);
      final floorWithRoomNumber = full.substring(2);
      final floorNumberRaw = full.substring(2, 4);
      final roomNumberRaw = full.substring(4);
      return DormitoryRoom(
        building: int.tryParse(buildingRaw) ?? 0,
        floorWithRoom: int.tryParse(floorWithRoomNumber) ?? 0,
        floor: int.tryParse(floorNumberRaw) ?? 0,
        room: int.tryParse(roomNumberRaw) ?? 0,
      );
    }
    // fallback
    return const DormitoryRoom(building: 0, floorWithRoom: 0, floor: 0, room: 0);
  }

  @override
  String toString() {
    return "Building $building #$floorWithRoom";
  }

  String l10n() {
    return "dormitoryRoom".tr(namedArgs: {
      "building": building.toString(),
      "room": floorWithRoom.toString(),
    });
  }

  static void quickSort(List<int> rooms, int Function(int, int) compare) {
    if (rooms.length < 2) {
      return;
    }

    List<int> stack = [];
    stack.add(0);
    stack.add(rooms.length - 1);

    while (stack.isNotEmpty) {
      int end = stack.removeLast();
      int start = stack.removeLast();

      int pivotIndex = partition(rooms, start, end, compare);

      if (pivotIndex - 1 > start) {
        stack.add(start);
        stack.add(pivotIndex - 1);
      }

      if (pivotIndex + 1 < end) {
        stack.add(pivotIndex + 1);
        stack.add(end);
      }
    }
  }

  static int partition(List<int> rooms, int start, int end, int Function(int, int) compare) {
    int pivot = rooms[end];
    int i = start - 1;

    for (int j = start; j < end; j++) {
      if (compare(rooms[j], pivot) <= 0) {
        i++;
        _swap(rooms, i, j);
      }
    }

    _swap(rooms, i + 1, end);
    return i + 1;
  }

  static void _swap(List<int> rooms, int i, int j) {
    int temp = rooms[i];
    rooms[i] = rooms[j];
    rooms[j] = temp;
  }

  static int compare(int room1, int room2) {
    var dormitoryRoom1 = DormitoryRoom.fromFullString(room1.toString());
    var dormitoryRoom2 = DormitoryRoom.fromFullString(room2.toString());
    if (dormitoryRoom1.building < dormitoryRoom2.building) {
      return -1;
    } else if (dormitoryRoom1.building > dormitoryRoom2.building) {
      return 1;
    } else {
      if (dormitoryRoom1.floor < dormitoryRoom2.floor) {
        return -1;
      } else if (dormitoryRoom1.floor > dormitoryRoom2.floor) {
        return 1;
      } else {
        if (dormitoryRoom1.room < dormitoryRoom2.room) {
          return -1;
        } else if (dormitoryRoom1.room > dormitoryRoom2.room) {
          return 1;
        } else {
          return 0;
        }
      }
    }
  }
}
