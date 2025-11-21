import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rettulf/rettulf.dart';

import '../../entity/display.dart';
import '../../entity/pos.dart';
import '../../entity/timetable_entity.dart';
import 'daily.dart';
import 'weekly.dart';

class TimetableBoard extends ConsumerWidget {
  final TimetableEntity timetable;
  final ValueNotifier<DisplayMode> $displayMode;
  final ValueNotifier<TimetablePos> $currentPos;

  const TimetableBoard({
    super.key,
    required this.timetable,
    required this.$displayMode,
    required this.$currentPos,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return $displayMode >>
        (ctx, mode) => AnimatedSwitcher(
              duration: Durations.short4,
              child: mode == DisplayMode.daily
                  ? DailyTimetable(
                      $currentPos: $currentPos,
                      timetable: timetable,
                    )
                  : WeeklyTimetable(
                      $currentPos: $currentPos,
                      timetable: timetable,
                    ),
            );
  }
}
