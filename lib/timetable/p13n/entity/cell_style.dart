import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mimir/utils/color.dart';

part "cell_style.g.dart";

@CopyWith(skipFields: true)
@JsonSerializable()
class CourseCellStyle {
  @JsonKey()
  final bool showTeachers;
  @JsonKey()
  final bool grayOutTakenLessons;
  @JsonKey()
  final bool harmonizeWithThemeColor;
  @JsonKey()
  final double alpha;

  const CourseCellStyle({
    this.showTeachers = true,
    this.grayOutTakenLessons = false,
    this.harmonizeWithThemeColor = true,
    this.alpha = 1.0,
  });

  Color decorateColor(
    Color color, {
    Color? themeColor,
    bool isLessonTaken = false,
  }) {
    final oldOpacity = color.opacity;
    // harmonizeWith will clear the opacity
    if (harmonizeWithThemeColor && themeColor != null) {
      color = color.harmonizeWith(themeColor);
    }
    if (grayOutTakenLessons && isLessonTaken) {
      color = color.monochrome();
    }
    // restore the opacity
    color = color.withOpacity(oldOpacity);
    if (alpha < 1.0) {
      color = color.withOpacity(color.opacity * alpha);
    }
    return color;
  }

  factory CourseCellStyle.fromJson(Map<String, dynamic> json) => _$CourseCellStyleFromJson(json);

  Map<String, dynamic> toJson() => _$CourseCellStyleToJson(this);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CourseCellStyle &&
            runtimeType == other.runtimeType &&
            showTeachers == other.showTeachers &&
            grayOutTakenLessons == other.grayOutTakenLessons &&
            harmonizeWithThemeColor == other.harmonizeWithThemeColor &&
            alpha == other.alpha;
  }

  @override
  int get hashCode => Object.hash(showTeachers, grayOutTakenLessons, harmonizeWithThemeColor, alpha);
}
