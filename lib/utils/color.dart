import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

extension ColorX on Color {
  Color monochrome({double progress = 1}) {
    final gray = 0.21 * r + 0.71 * g + 0.07 * b;
    final iProgress = 1.0 - progress;
    return Color.from(
      alpha: a,
      red: r * iProgress + gray * progress,
      green: g * iProgress + gray * progress,
      blue: b * iProgress + gray * progress,
    );
  }

  double get luminance => (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0;

  double get brightness => (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
}

extension SystemAccentColorX on SystemAccentColor {
  Color? get maybeAccent => supportsSystemAccentColor ? accent : null;
}

bool get supportsSystemAccentColor => defaultTargetPlatform.supportsAccentColor;

Color? findBestTextColor(Color bgColor, List<Color> textColors) {
  // final sorted = textColors.sortedBy<num>((textColor) => calculateContrastRatio(textColor, bgColor));
  final map =
      Map.fromEntries(textColors.map((textColor) => MapEntry(calculateContrastRatio(textColor, bgColor), textColor)));
  final sorted = map.entries.sortedBy<num>((e) => e.key).toList();
  final res = sorted.lastOrNull?.value;
  return res;
}

double calculateContrastRatio(Color color1, Color color2) {
  final luminance1 = color1.luminance;
  final luminance2 = color2.luminance;
  final contrast = (luminance1 + 0.05) / (luminance2 + 0.05);
  if (contrast < 1) {
    return 1 / contrast;
  }
  return contrast;
}
