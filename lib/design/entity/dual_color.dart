import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rettulf/rettulf.dart';

part "dual_color.g.dart";

int _colorToJson(Color color) => color.toARGB32();

Color _colorFromJson(int value) => Color(value);

@JsonSerializable()
@CopyWith(skipFields: true)
class ColorEntry {
  @JsonKey(toJson: _colorToJson, fromJson: _colorFromJson)
  final Color color;
  final bool inverseText;

  const ColorEntry(
    this.color, {
    this.inverseText = false,
  });

  const ColorEntry.inverse(
    this.color,
  ) : inverseText = true;

  factory ColorEntry.fromJson(Map<String, dynamic> json) => _$ColorEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ColorEntryToJson(this);

  @override
  String toString() {
    return "ColorEntry${inverseText ? ".inverse" : ""}(Color(0x${color.hexAlpha}))";
  }
}

@JsonSerializable()
@CopyWith(skipFields: true)
class DualColor {
  final ColorEntry light;
  final ColorEntry dark;

  const DualColor({
    required this.light,
    required this.dark,
  });

  DualColor.plain({
    required Color light,
    required Color dark,
  })  : light = ColorEntry(light),
        dark = ColorEntry(dark);

  factory DualColor.fromJson(Map<String, dynamic> json) => _$DualColorFromJson(json);

  Map<String, dynamic> toJson() => _$DualColorToJson(this);

  @override
  String toString() {
    return "DualColor(light:$light,dark:$dark)";
  }
}

extension ColorEntryX on ColorEntry {
  Color textColor(BuildContext context) =>
      inverseText ? context.colorScheme.onInverseSurface : context.colorScheme.onSurface;
}

extension DualColorX on DualColor {
  ColorEntry byBrightness(Brightness brightness) => brightness == Brightness.dark ? dark : light;

  ColorEntry byContext(BuildContext context) => context.isDarkMode ? dark : light;

  Color colorBy(BuildContext context) => (context.isDarkMode ? dark : light).color;

  Color textColorBy(BuildContext context) => (context.isDarkMode ? dark : light).textColor(context);
}
