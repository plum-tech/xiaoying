import 'package:flutter/material.dart';
import 'package:mimir/design/entity/dual_color.dart';
import 'package:mimir/timetable/p13n/entity/palette.dart';

import '../entity/timetable.dart';

/// https://m3.material.io/theme-builder#/custom
class BuiltinTimetablePalettes {
  static const classic = BuiltinTimetablePalette(
    uuid: "297a0b7c-ef53-4d5e-a76b-ac678f3e9386",
    key: "classic",
    author: "Li_plum@outlook.com",
    colors: [
      DualColor(dark: ColorEntry(Color(0xdf356a21)), light: ColorEntry(Color(0xd2a7d99b))),
      DualColor(dark: ColorEntry(Color(0xdf00739b)), light: ColorEntry(Color(0xd2cbe3ef))),
      DualColor(dark: ColorEntry(Color(0xdf8e2f56)), light: ColorEntry(Color(0xd2ffa6bb))),
      DualColor(dark: ColorEntry(Color(0xdf50378a)), light: ColorEntry(Color(0xd2b8a4ea))),
      DualColor(dark: ColorEntry(Color(0xdfac5029)), light: ColorEntry(Color(0xd2ecab8a))),
      DualColor(dark: ColorEntry(Color(0xdf80002d)), light: ColorEntry(Color(0xd2eeb6d3))),
      DualColor(dark: ColorEntry(Color(0xdf7c5800)), light: ColorEntry(Color(0xd2eadea1))),
      DualColor(dark: ColorEntry(Color(0xdf006b5f)), light: ColorEntry(Color(0xd292c7b8))),
      DualColor(dark: ColorEntry(Color(0xdf004e5f)), light: ColorEntry(Color(0xd2aaccd8))),
      DualColor(dark: ColorEntry(Color(0xdf7c157a)), light: ColorEntry(Color(0xd2ffd7f5))),
      DualColor(dark: ColorEntry(Color(0xdf616200)), light: ColorEntry(Color(0xd2d9dc89))),
    ],
  );

  static const all = [
    classic,
  ];

  static final uuid2palette = Map.fromEntries(all.map((p) => MapEntry(p.uuid, p)));
}

extension TimetablePlatteX on TimetablePalette {
  DualColor resolveColor(Course course) {
    assert(colors.isNotEmpty, "Colors can't be empty");
    if (colors.isEmpty) return TimetablePalette.defaultColor;
    return colors[course.courseCode.hashCode.abs() % colors.length];
  }

  DualColor safeGetColor(int index) {
    assert(colors.isNotEmpty, "Colors can't be empty");
    if (colors.isEmpty) return TimetablePalette.defaultColor;
    return colors[index % colors.length];
  }
}
