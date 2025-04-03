import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mimir/design/entity/dual_color.dart';
import 'package:mimir/entity/uuid.dart';
import 'package:uuid/uuid.dart';

import '../../entity/timetable.dart';

part 'palette.g.dart';

DateTime _kLastModified() => DateTime.now();

String _kUUid() => const Uuid().v4();

@JsonSerializable()
@CopyWith()
class TimetablePalette implements WithUuid {
  static int maxNameLength = 50;

  /// Since v1, the [colors] is in type of [({Color light, Color dark})].
  /// Since v2, the text color can be inverse.
  /// Since v3, the [uuid] was added.
  static const version = 3;
  @override
  @JsonKey(defaultValue: _kUUid)
  final String uuid;
  @JsonKey()
  final String name;
  @JsonKey()
  final String author;
  @_DualColorMigratedFromColor2ModeConverter()
  final List<DualColor> colors;
  @JsonKey(defaultValue: _kLastModified)
  final DateTime lastModified;

  static const defaultColor = DualColor(
    light: ColorEntry(Colors.white),
    dark: ColorEntry(Colors.black),
  );

  const TimetablePalette({
    required this.uuid,
    required this.name,
    required this.author,
    required this.colors,
    required this.lastModified,
  });

  factory TimetablePalette.create({
    required String name,
    required String author,
    required List<DualColor> colors,
  }) {
    return TimetablePalette(
      uuid: _kUUid(),
      name: name,
      author: author,
      colors: colors,
      lastModified: DateTime.now(),
    );
  }

  factory TimetablePalette.fromJson(Map<String, dynamic> json) => _$TimetablePaletteFromJson(json);

  Map<String, dynamic> toJson() => _$TimetablePaletteToJson(this);
}

class _DualColorMigratedFromColor2ModeConverter implements JsonConverter<DualColor, Map> {
  const _DualColorMigratedFromColor2ModeConverter();

  @override
  DualColor fromJson(Map json) {
    final light = json["light"];
    final dark = json["dark"];
    if (light is num && dark is num) {
      return DualColor.plain(
        light: Color(light.toInt()),
        dark: Color(dark.toInt()),
      );
    } else {
      return DualColor.fromJson(json.cast());
    }
  }

  @override
  Map toJson(DualColor object) => object.toJson();
}

extension TimetablePaletteX on TimetablePalette {
  TimetablePalette markModified() {
    return copyWith(
      lastModified: DateTime.now(),
    );
  }
}

class BuiltinTimetablePalette implements TimetablePalette {
  final String key;
  @override
  final String uuid;
  final String? nameOverride;
  final String? authorOverride;

  @override
  String get name => nameOverride ?? "timetable.p13n.palette.builtin.$key.name".tr();

  @override
  String get author => authorOverride ?? "timetable.p13n.palette.builtin.$key.author".tr();
  @override
  final List<DualColor> colors;

  @override
  DateTime get lastModified => DateTime.now();

  const BuiltinTimetablePalette({
    required this.key,
    required this.uuid,
    required this.colors,
    String? name,
    String? author,
  })  : nameOverride = name,
        authorOverride = author;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        "uuid": uuid,
        "author": author,
        "colors": colors,
      };
}

abstract mixin class TimetablePaletteResolver {
  Timetable get type;

  factory TimetablePaletteResolver(Timetable type) {
    return _TimetablePaletteResolverImpl(type: type);
  }

  final _fixedCourseCode2Color = <TimetablePalette, Map<String, DualColor>>{};

  DualColor resolveColor(TimetablePalette palette, Course course) {
    assert(palette.colors.isNotEmpty, "Colors can't be empty");
    if (palette.colors.isEmpty) return TimetablePalette.defaultColor;
    assert(type.courses.containsValue(course), "Course $course not found in this timetable");

    final fixedCourseCode2Color = _fixedCourseCode2Color[palette] ?? _cacheFixedCourseCode2Color(palette);
    return fixedCourseCode2Color[course.courseCode] ??
        palette.colors[course.courseCode.hashCode.abs() % palette.colors.length];
  }

  Map<String, DualColor> _cacheFixedCourseCode2Color(TimetablePalette palette) {
    final queue = List.of(palette.colors);
    final fixedCourseCode2Color = <String, DualColor>{};
    for (final course in type.courses.values) {
      if (queue.isEmpty) break;
      final index = course.courseCode.hashCode.abs() % queue.length;
      // allocate a color for this course code
      fixedCourseCode2Color[course.courseCode] = queue[index];
      // remove it in the next loop
      queue.removeAt(index);
    }
    return fixedCourseCode2Color;
  }
}

class _TimetablePaletteResolverImpl with TimetablePaletteResolver {
  @override
  final Timetable type;

  _TimetablePaletteResolverImpl({
    required this.type,
  });
}
