import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/timetable/p13n/entity/palette.dart';

import '../../init.dart';
import '../builtin.dart';
import '../entity/cell_style.dart';

part "style.g.dart";

@CopyWith(skipFields: true)
class TimetableStyleData {
  final TimetablePalette platte;
  final CourseCellStyle cellStyle;

  const TimetableStyleData({
    this.platte = BuiltinTimetablePalettes.classic,
    this.cellStyle = const CourseCellStyle(),
  });

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is TimetableStyleData &&
        runtimeType == other.runtimeType &&
        platte == other.platte &&
        cellStyle == other.cellStyle;
  }
}

class TimetableStyle extends InheritedWidget {
  final TimetableStyleData data;

  const TimetableStyle({
    super.key,
    required this.data,
    required super.child,
  });

  static TimetableStyleData of(BuildContext context) {
    final TimetableStyle? result = context.dependOnInheritedWidgetOfExactType<TimetableStyle>();
    assert(result != null, 'No TimetableStyle found in context');
    return result!.data;
  }

  static TimetableStyleData? maybeOf(BuildContext context) {
    final TimetableStyle? result = context.dependOnInheritedWidgetOfExactType<TimetableStyle>();
    return result?.data;
  }

  @override
  bool updateShouldNotify(TimetableStyle oldWidget) {
    return data != oldWidget.data;
  }
}

class TimetableStyleProv extends ConsumerStatefulWidget {
  final Widget? child;
  final TimetablePalette? palette;
  final CourseCellStyle? cellStyle;

  final Widget Function(BuildContext context, TimetableStyleData style)? builder;

  const TimetableStyleProv({
    super.key,
    this.child,
    this.builder,
    this.palette,
    this.cellStyle,
  }) : assert(builder != null || child != null, "TimetableStyleProv should have at least one child.");

  @override
  ConsumerState createState() => TimetableStyleProvState();
}

class TimetableStyleProvState extends ConsumerState<TimetableStyleProv> {
  final $palette = TimetableInit.storage.palette.$selected;
  var palette = TimetableInit.storage.palette.selectedRow ?? BuiltinTimetablePalettes.classic;

  @override
  void initState() {
    super.initState();
    $palette.addListener(refreshPalette);
  }

  @override
  void dispose() {
    $palette.removeListener(refreshPalette);
    super.dispose();
  }

  void refreshPalette() {
    setState(() {
      palette = TimetableInit.storage.palette.selectedRow ?? BuiltinTimetablePalettes.classic;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cellStyle = ref.watch(Settings.timetable.$cellStyle) ?? const CourseCellStyle();
    final data = TimetableStyleData(
      platte: palette,
      cellStyle: cellStyle,
    ).copyWith(
      platte: widget.palette,
      cellStyle: widget.cellStyle,
    );
    return TimetableStyle(
      data: data,
      child: buildChild(data),
    );
  }

  Widget buildChild(TimetableStyleData data) {
    final child = widget.child;
    if (child != null) {
      return child;
    }
    final builder = widget.builder;
    if (builder != null) {
      return Builder(builder: (ctx) => builder(ctx, data));
    }
    return const SizedBox.shrink();
  }
}
