// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_entity.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TimetableLessonSlotCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableLessonSlot(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableLessonSlot call({
    List<TimetableLessonPart>? lessons,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTimetableLessonSlot.copyWith(...)`.
class _$TimetableLessonSlotCWProxyImpl implements _$TimetableLessonSlotCWProxy {
  const _$TimetableLessonSlotCWProxyImpl(this._value);

  final TimetableLessonSlot _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableLessonSlot(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableLessonSlot call({
    Object? lessons = const $CopyWithPlaceholder(),
  }) {
    return TimetableLessonSlot(
      lessons: lessons == const $CopyWithPlaceholder() || lessons == null
          ? _value.lessons
          // ignore: cast_nullable_to_non_nullable
          : lessons as List<TimetableLessonPart>,
    );
  }
}

extension $TimetableLessonSlotCopyWith on TimetableLessonSlot {
  /// Returns a callable class that can be used as follows: `instanceOfTimetableLessonSlot.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TimetableLessonSlotCWProxy get copyWith => _$TimetableLessonSlotCWProxyImpl(this);
}

abstract class _$TimetableLessonCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableLesson(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableLesson call({
    Course? course,
    List<TimetableLessonPart>? parts,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTimetableLesson.copyWith(...)`.
class _$TimetableLessonCWProxyImpl implements _$TimetableLessonCWProxy {
  const _$TimetableLessonCWProxyImpl(this._value);

  final TimetableLesson _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableLesson(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableLesson call({
    Object? course = const $CopyWithPlaceholder(),
    Object? parts = const $CopyWithPlaceholder(),
  }) {
    return TimetableLesson(
      course: course == const $CopyWithPlaceholder() || course == null
          ? _value.course
          // ignore: cast_nullable_to_non_nullable
          : course as Course,
      parts: parts == const $CopyWithPlaceholder() || parts == null
          ? _value.parts
          // ignore: cast_nullable_to_non_nullable
          : parts as List<TimetableLessonPart>,
    );
  }
}

extension $TimetableLessonCopyWith on TimetableLesson {
  /// Returns a callable class that can be used as follows: `instanceOfTimetableLesson.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TimetableLessonCWProxy get copyWith => _$TimetableLessonCWProxyImpl(this);
}

abstract class _$TimetableLessonPartCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableLessonPart(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableLessonPart call({
    TimetableLesson? type,
    int? index,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTimetableLessonPart.copyWith(...)`.
class _$TimetableLessonPartCWProxyImpl implements _$TimetableLessonPartCWProxy {
  const _$TimetableLessonPartCWProxyImpl(this._value);

  final TimetableLessonPart _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableLessonPart(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableLessonPart call({
    Object? type = const $CopyWithPlaceholder(),
    Object? index = const $CopyWithPlaceholder(),
  }) {
    return TimetableLessonPart(
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as TimetableLesson,
      index: index == const $CopyWithPlaceholder() || index == null
          ? _value.index
          // ignore: cast_nullable_to_non_nullable
          : index as int,
    );
  }
}

extension $TimetableLessonPartCopyWith on TimetableLessonPart {
  /// Returns a callable class that can be used as follows: `instanceOfTimetableLessonPart.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TimetableLessonPartCWProxy get copyWith => _$TimetableLessonPartCWProxyImpl(this);
}
