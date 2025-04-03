import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/l10n/time.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/entity/timetable.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/timetable/utils.dart';
import 'package:collection/collection.dart';
import 'package:mimir/utils/date.dart';
import '../p13n/entity/palette.dart';
import 'timetable.dart';

part "timetable_entity.g.dart";

/// The entity to display.
class TimetableEntity with TimetablePaletteResolver, CourseCodeIndexer {
  @override
  final Timetable type;

  @override
  Iterable<Course> get courses => type.courses.values;

  final List<TimetableDay> days;

  /// The Default number of weeks is 20.
  List<TimetableWeek> weeks() => List.generate(maxWeekLength, (index) => getWeek(index));

  TimetableWeek getWeek(int weekIndex) {
    return TimetableWeek(days.sublist(weekIndex * 7, weekIndex * 7 + 7));
  }

  TimetableDay getDay(int weekIndex, Weekday weekday) {
    return days[weekIndex * 7 + weekday.index];
  }

  TimetableEntity({
    required this.type,
    required this.days,
  }) {
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

  TimetableDay? getDaySinceStart(int days) {
    return this.days[days - 1];
  }

  TimetableWeek? getWeekOn(DateTime date) {
    if (startDate.isAfter(date)) return null;
    final diff = date.difference(startDate);
    if (diff.inDays > maxWeekLength * 7) return null;
    final weekIndex = diff.inDays ~/ 7;
    if (weekIndex < 0 || weekIndex >= maxWeekLength) return null;
    return getWeek(weekIndex);
  }

  TimetableDay? getDayOn(DateTime date) {
    if (startDate.isAfter(date)) return null;
    final diff = date.difference(startDate);
    if (diff.inDays > maxWeekLength * 7) return null;
    return days.elementAtOrNull(diff.inDays);
  }
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

  List<TimetableLessonSlot> get timeslot2LessonSlot => UnmodifiableListView(slots);

  late final Set<Course> _associatedCourses =
      slots.map((slot) => slot.lessons).flattened.map((part) => part.course).toSet();

  Set<Course> get associatedCourses => UnmodifiableSetView(_associatedCourses);

  bool _frozen = false;

  bool get frozen => _frozen;

  void freeze() {
    _frozen = true;
    throw UnimplementedError();
  }

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
      List.generate(11, (index) => TimetableLessonSlot(lessons: <TimetableLessonPart>[])),
    );
  }

  bool get isFree => slots.every((lessonSlot) => lessonSlot.lessons.isEmpty);

  void add({required TimetableLessonPart lesson, required int at}) {
    if (frozen) throw throw UnsupportedError("Cannot modify a frozen $TimetableDay.");
    assert(0 <= at && at < slots.length);
    if (0 <= at && at < slots.length) {
      final lessonSlot = slots[at];
      lessonSlot.lessons.add(lesson);
      lesson.type.parent = this;
    }
  }

  void clear() {
    if (frozen) throw throw UnsupportedError("Cannot modify a frozen $TimetableDay.");
    for (final lessonSlot in slots) {
      lessonSlot.lessons.clear();
    }
  }

  void replaceWith(TimetableDay other) {
    // timeslot2LessonSlot
    setLessonSlots(other.cloneLessonSlots());
  }

  void swap(TimetableDay other) {
    // timeslot2LessonSlot
    final $timeslot2LessonSlot = other.cloneLessonSlots();
    other.setLessonSlots(cloneLessonSlots());
    setLessonSlots($timeslot2LessonSlot);
  }

  void setLessonSlots(Iterable<TimetableLessonSlot> v) {
    slots.clear();
    slots.addAll(v);

    for (final lessonSlot in slots) {
      lessonSlot.parent = this;
      for (final part in lessonSlot.lessons) {
        part.type.parent = this;
      }
    }
  }

  List<TimetableLessonSlot> cloneLessonSlots() {
    final old2newLesson = <TimetableLesson, TimetableLesson>{};
    final timeslots = List.of(
      slots.map(
        (lessonSlot) {
          return TimetableLessonSlot(
            lessons: List.of(
              lessonSlot.lessons.map(
                (lessonPart) {
                  final oldLesson = lessonPart.type;
                  final lesson = old2newLesson[oldLesson] ??
                      oldLesson.copyWith(
                        parts: [],
                      );
                  old2newLesson[oldLesson] ??= lesson;
                  final part = lessonPart.copyWith(
                    type: lesson,
                  );
                  return part;
                },
              ),
            ),
          );
        },
      ),
    );

    for (final slot in timeslots) {
      for (final lessonPart in slot.lessons) {
        lessonPart.type.parts
            .addAll(timeslots.map((slot) => slot.lessons).flattened.where((part) => part.type == lessonPart.type));
      }
    }
    return timeslots;
  }

  /// At all lessons [layer]
  Iterable<TimetableLessonPart> browseLessonsAt({required int layer}) sync* {
    for (final lessonSlot in slots) {
      if (0 <= layer && layer < lessonSlot.lessons.length) {
        yield lessonSlot.lessons[layer];
      }
    }
  }

  bool hasAnyLesson() {
    for (final lessonSlot in slots) {
      if (lessonSlot.lessons.isNotEmpty) {
        assert(associatedCourses.isNotEmpty);
        return true;
      }
    }
    return false;
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

  TimetableLesson({
    required this.course,
    required this.parts,
  });

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
      final classTime = calcBeginEndTimePointOfLesson(index, type.parent.parent.type.campus, course.place);
      _dayCache = type.parent;
      final time = (start: thatDay.addTimePoint(classTime.begin), end: thatDay.addTimePoint(classTime.end));
      _timeCache = time;
      return time;
    }
  }

  DateTime get startTime => time.start;

  DateTime get endTime => time.end;

  Course get course => type.course;

  TimetableLessonPart({
    required this.type,
    required this.index,
  });

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
          final lesson = TimetableLesson(
            course: course,
            parts: parts,
          );
          for (int slot = timeslots.start; slot <= timeslots.end; slot++) {
            final part = TimetableLessonPart(
              type: lesson,
              index: slot,
            );
            parts.add(part);
            day.add(
              at: slot,
              lesson: part,
            );
          }
        }
      }
    }
    final entity = TimetableEntity(
      type: this,
      days: days,
    );

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
