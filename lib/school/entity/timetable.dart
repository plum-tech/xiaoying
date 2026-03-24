import 'package:mimir/entity/campus.dart';

class TimePoint {
  final int hour;
  final int minute;

  const TimePoint(this.hour, this.minute);

  const TimePoint.fromMinutes(int minutes)
    : hour = minutes ~/ 60,
      minute = minutes % 60;

  @override
  String toString() => '$hour:${'$minute'.padLeft(2, '0')}';

  String toStringPrefixed0({bool hour = true, bool minute = true}) {
    final sb = StringBuffer();
    if (hour) {
      sb.write(this.hour.toString().padLeft(2, '0'));
    } else {
      sb.write(this.hour.toString());
    }
    sb.write(':');
    if (minute) {
      sb.write(this.minute.toString().padLeft(2, '0'));
    } else {
      sb.write(this.minute.toString());
    }
    return sb.toString();
  }

  String get label => '$hour:${'$minute'.padLeft(2, '0')}';

  TimeDuration difference(TimePoint b) =>
      TimeDuration.fromMinutes(totalMinutes - b.totalMinutes);

  TimePoint operator -(TimeDuration b) =>
      TimePoint.fromMinutes(totalMinutes - b.totalMinutes);

  TimePoint operator +(TimeDuration b) =>
      TimePoint.fromMinutes(totalMinutes + b.totalMinutes);

  int get totalMinutes => hour * 60 + minute;
}

extension DateTimeTimePointX on DateTime {
  DateTime addTimePoint(TimePoint t) {
    return add(Duration(hours: t.hour, minutes: t.minute));
  }
}

class TimeDuration {
  final int hour;
  final int minute;

  int get totalMinutes => hour * 60 + minute;

  const TimeDuration(this.hour, this.minute);

  const TimeDuration.fromMinutes(int minutes)
    : hour = minutes ~/ 60,
      minute = minutes % 60;

  String get label {
    final h = "$hour";
    final min = "$minute".padLeft(2, '0');
    if (hour == 0) {
      return "$min 分钟";
    } else if (minute == 0) {
      return "$h 小时";
    }
    return "$h 小时 $min 分钟";
  }

  Duration toDuration() => Duration(hours: hour, minutes: minute);
}

typedef ClassTime = ({TimePoint begin, TimePoint end});

extension ClassTimeX on ClassTime {
  TimeDuration get duration {
    return end.difference(begin);
  }
}

const defaultCampusTimetable = <ClassTime>[
  // morning
  (begin: TimePoint(8, 20), end: TimePoint(9, 05)),
  (begin: TimePoint(9, 10), end: TimePoint(9, 55)),
  (begin: TimePoint(10, 10), end: TimePoint(10, 55)),
  (begin: TimePoint(11, 00), end: TimePoint(11, 45)),
  // afternoon
  (begin: TimePoint(13, 00), end: TimePoint(13, 45)),
  (begin: TimePoint(13, 50), end: TimePoint(14, 35)),
  (begin: TimePoint(14, 55), end: TimePoint(15, 40)),
  (begin: TimePoint(15, 45), end: TimePoint(16, 30)),
  // night
  (begin: TimePoint(18, 00), end: TimePoint(18, 45)),
  (begin: TimePoint(18, 50), end: TimePoint(19, 35)),
  (begin: TimePoint(19, 40), end: TimePoint(20, 25)),
];

List<ClassTime> getTeachingBuildingTimetable(Campus campus, [String? place]) {
  return defaultCampusTimetable;
}
