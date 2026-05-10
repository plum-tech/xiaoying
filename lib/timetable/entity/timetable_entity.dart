import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/entity/timetable.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/timetable/utils.dart';
import 'package:collection/collection.dart';
import 'package:mimir/utils/date.dart';
import 'package:mimir/utils/weekday.dart';
import 'timetable.dart';

part "timetable_entity.g.dart";

/// The entity to display.
class TimetableEntity with CourseCodeIndexer {
  final Timetable type;

  @override
  Iterable<Course> get courses => type.courses.values;

  final List<TimetableDay> days;

  /// The Default number of weeks is 20.
  List<TimetableWeek> weeks() =>
      List.generate(maxWeekLength, (index) => getWeek(index));

  TimetableWeek getWeek(int weekIndex) {
    return TimetableWeek(days.sublist(weekIndex * 7, weekIndex * 7 + 7));
  }

  TimetableDay getDay(int weekIndex, Weekday weekday) {
    return days[weekIndex * 7 + weekday.index];
  }

  TimetableEntity({required this.type, required this.days}) {
    for (final day in days) {
      day.parent = this;
    }
  }

  String get name => type.name;

  DateTime get startDate => type.startDate;

  int get schoolYear => type.schoolYear;

  Semester get semester => type.semester;

  Campus get campus => type.campus;

  String get signature => type.signature;
}

extension type TimetableWeek(List<TimetableDay> days) {
  int get index => days.first.weekIndex;

  bool get isFree => days.every((day) => day.isFree);

  TimetableDay operator [](Weekday weekday) => days[weekday.index];

  operator []=(Weekday weekday, TimetableDay day) => days[weekday.index] = day;
}

/// Lessons in the same timeslot.
@CopyWith(skipFields: true)
class TimetableLessonSlot {
  late final TimetableDay parent;
  final List<TimetableLessonPart> lessons;

  TimetableLessonSlot({required this.lessons});

  TimetableLessonPart? lessonAt(int index) {
    return lessons.elementAtOrNull(index);
  }

  @override
  String toString() {
    return "${_formatDay(parent.date)} $lessons".toString();
  }
}

String _formatDay(DateTime date) {
  return "${date.year}/${date.month}/${date.day}";
}

String _formatTime(DateTime date) {
  return "${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute}";
}

class TimetableDay {
  late final TimetableEntity parent;

  final int weekIndex;
  final Weekday weekday;

  /// The Default number of lessons in one day is 11. But it can be extended.
  /// For example,
  /// A Timeslot could contain one or more lesson.
  final List<TimetableLessonSlot> slots;

  List<TimetableLessonSlot> get timeslot2LessonSlot =>
      UnmodifiableListView(slots);

  DateTime get date => reflectWeekDayIndexToDate(
    startDate: parent.startDate,
    weekIndex: weekIndex,
    weekday: weekday,
  );

  TimetableDay({
    required int weekIndex,
    required Weekday weekday,
    required List<TimetableLessonSlot> timeslot2LessonSlot,
  }) : this._internal(weekIndex, weekday, List.of(timeslot2LessonSlot));

  TimetableDay._internal(this.weekIndex, this.weekday, this.slots) {
    for (final lessonSlot in timeslot2LessonSlot) {
      lessonSlot.parent = this;
    }
  }

  factory TimetableDay.$11slots({
    required int weekIndex,
    required Weekday weekday,
  }) {
    return TimetableDay._internal(
      weekIndex,
      weekday,
      List.generate(
        11,
        (index) => TimetableLessonSlot(lessons: <TimetableLessonPart>[]),
      ),
    );
  }

  bool get isFree => slots.every((lessonSlot) => lessonSlot.lessons.isEmpty);

  void add({required TimetableLessonPart lesson, required int at}) {
    assert(0 <= at && at < slots.length);
    if (0 <= at && at < slots.length) {
      final lessonSlot = slots[at];
      lessonSlot.lessons.add(lesson);
      lesson.type.parent = this;
    }
  }

  void clear() {
    for (final lessonSlot in slots) {
      lessonSlot.lessons.clear();
    }
  }

  @override
  String toString() {
    return "${_formatDay(date)} [$weekIndex-${weekday.index}] $slots";
  }
}

@CopyWith(skipFields: true)
class TimetableLesson {
  late TimetableDay parent;

  /// A lesson may last two or more time slots.
  /// If current [TimetableLessonPart] is a part of the whole lesson, they all have the same [courseKey].
  final Course course;

  /// in timeslot order
  final List<TimetableLessonPart> parts;

  TimetableLesson({required this.course, required this.parts});

  /// How many timeslots this lesson takes.
  /// It's at least 1 timeslot.
  int get timeslotDuration => endIndex - startIndex + 1;

  /// The start index of this lesson in a [TimetableWeek]
  int get startIndex => parts.first.index;

  /// The end index of this lesson in a [TimetableWeek]
  int get endIndex => parts.last.index;

  DateTime get startTime => parts.first.startTime;

  DateTime get endTime => parts.last.endTime;

  @override
  String toString() {
    return "${course.courseName} ${_formatTime(startTime)} => ${_formatTime(endTime)}";
  }
}

@CopyWith(skipFields: true)
class TimetableLessonPart {
  final TimetableLesson type;

  /// The start index of this lesson in a [TimetableWeek]
  final int index;

  late TimetableDay _dayCache = type.parent;

  ({DateTime start, DateTime end})? _timeCache;

  ({DateTime start, DateTime end}) get time {
    final timeCache = _timeCache;

    if (_dayCache == type.parent && timeCache != null) {
      return timeCache;
    } else {
      final thatDay = type.parent.date;
      final classTime = calcBeginEndTimePointOfLesson(
        index,
        type.parent.parent.type.campus,
        course.place,
      );
      _dayCache = type.parent;
      final time = (
        start: thatDay.addTimePoint(classTime.begin),
        end: thatDay.addTimePoint(classTime.end),
      );
      _timeCache = time;
      return time;
    }
  }

  DateTime get startTime => time.start;

  DateTime get endTime => time.end;

  Course get course => type.course;

  TimetableLessonPart({required this.type, required this.index});

  @override
  String toString() => "[$index] $type";
}

extension Timetable4EntityX on Timetable {
  TimetableEntity resolve() {
    final days = List.generate(
      maxWeekLength * 7,
      (index) => TimetableDay.$11slots(
        weekIndex: index ~/ 7,
        weekday: Weekday.fromIndex(index % 7),
      ),
    );

    for (final course in courses.values) {
      if (course.hidden) continue;
      final timeslots = course.timeslots;
      for (final weekIndex in course.weekIndices.getWeekIndices()) {
        assert(
          0 <= weekIndex && weekIndex < maxWeekLength,
          "Week index is more out of range [0,$maxWeekLength) but $weekIndex.",
        );
        if (0 <= weekIndex && weekIndex < maxWeekLength) {
          final day = days[weekIndex * 7 + course.dayIndex];
          final parts = <TimetableLessonPart>[];
          final lesson = TimetableLesson(course: course, parts: parts);
          for (int slot = timeslots.start; slot <= timeslots.end; slot++) {
            final part = TimetableLessonPart(type: lesson, index: slot);
            parts.add(part);
            day.add(at: slot, lesson: part);
          }
        }
      }
    }
    final entity = TimetableEntity(type: this, days: days);

    if (kDebugMode) {
      for (final day in entity.days) {
        for (final slot in day.timeslot2LessonSlot) {
          assert(slot.parent == day);
          for (final lessonPart in slot.lessons) {
            assert(lessonPart.type.parts.contains(lessonPart));
            assert(lessonPart.type.startTime.inTheSameDay(day.date));
          }
        }
      }
    }
    return entity;
  }
}
