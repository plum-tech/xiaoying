import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:mimir/design/dash.dart';
import 'package:mimir/design/entity/dual_color.dart';
import 'package:mimir/l10n/time.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/settings/settings.dart';
import 'package:rettulf/rettulf.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../events.dart';
import '../../entity/timetable.dart';
import '../../entity/timetable_entity.dart';
import 'course_sheet.dart';
import '../../utils.dart';
import '../free.dart';
import 'header.dart';
import '../../p13n/widget/style.dart';
import '../../entity/pos.dart';
import '../../i18n.dart';

class WeeklyTimetable extends StatefulWidget {
  final TimetableEntity timetable;

  final ValueNotifier<TimetablePos> $currentPos;

  @override
  State<StatefulWidget> createState() => WeeklyTimetableState();

  const WeeklyTimetable({
    super.key,
    required this.timetable,
    required this.$currentPos,
  });
}

class WeeklyTimetableState extends State<WeeklyTimetable> {
  late PageController pageController;
  final $cellSize = ValueNotifier(Size.zero);

  TimetableEntity get timetable => widget.timetable;

  TimetablePos get currentPos => widget.$currentPos.value;

  set currentPos(TimetablePos newValue) => widget.$currentPos.value = newValue;
  late StreamSubscription<JumpToPosEvent> $jumpToPos;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPos.weekIndex)
      ..addListener(() {
        setState(() {
          final newWeek = (pageController.page ?? 0).round();
          if (newWeek != currentPos.weekIndex) {
            currentPos = currentPos.copyWith(weekIndex: newWeek);
          }
        });
      });
    $jumpToPos = eventBus.on<JumpToPosEvent>().listen((event) {
      jumpTo(event.where);
    });
  }

  @override
  void dispose() {
    $jumpToPos.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.horizontal,
      itemCount: 20,
      itemBuilder: (ctx, weekIndex) {
        return TimetableOneWeekCached(
          timetable: timetable,
          weekIndex: weekIndex,
        );
      },
    );
  }

  /// 跳到某一周
  void jumpTo(TimetablePos pos) {
    if (pageController.hasClients) {
      final targetOffset = pos.weekIndex;
      final currentPos = pageController.page ?? targetOffset;
      final distance = (targetOffset - currentPos).abs();
      pageController.animateToPage(
        targetOffset,
        duration: calcuSwitchAnimationDuration(distance),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    }
  }
}

class TimetableOneWeekCached extends StatefulWidget {
  final TimetableEntity timetable;
  final int weekIndex;

  const TimetableOneWeekCached({
    super.key,
    required this.timetable,
    required this.weekIndex,
  });

  @override
  State<TimetableOneWeekCached> createState() => _TimetableOneWeekCachedState();
}

class _TimetableOneWeekCachedState extends State<TimetableOneWeekCached> with AutomaticKeepAliveClientMixin {
  /// Cache the entire page to avoid expensive rebuilding.
  Widget? _cached;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    _cached = null;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant TimetableOneWeekCached oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timetable != oldWidget.timetable) {
      _cached = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cache = _cached;
    if (cache != null) {
      return cache;
    } else {
      final style = TimetableStyle.of(context);
      final now = DateTime.now();
      Widget buildCell({
        required BuildContext context,
        required TimetableLessonPart lesson,
        required TimetableEntity timetable,
      }) {
        final inClassNow = lesson.type.startTime.isBefore(now) && lesson.type.endTime.isAfter(now);
        final passed = lesson.type.endTime.isBefore(now);
        Widget cell = InteractiveCourseCell(
          lesson: lesson,
          style: style,
          timetable: timetable,
          isLessonTaken: passed,
        );
        if (inClassNow) {
          // cell = Card.outlined(
          //   margin: const EdgeInsets.all(1),
          //   child: cell.padAll(1),
          // );
        }
        return cell;
      }

      final res = LayoutBuilder(
        builder: (context, box) {
          return TimetableOneWeek(
            fullSize: Size(box.maxWidth, box.maxHeight * 1.2),
            timetable: widget.timetable,
            weekIndex: widget.weekIndex,
            showFreeTip: true,
            cellBuilder: buildCell,
          ).scrolled();
        },
      );
      _cached = res;
      return res;
    }
  }
}

class TimetableOneWeek extends StatelessWidget {
  final TimetableEntity timetable;
  final int weekIndex;
  final Size fullSize;
  final bool showFreeTip;
  final Widget Function({
    required BuildContext context,
    required TimetableLessonPart lesson,
    required TimetableEntity timetable,
  }) cellBuilder;

  const TimetableOneWeek({
    super.key,
    required this.timetable,
    required this.weekIndex,
    required this.fullSize,
    required this.cellBuilder,
    this.showFreeTip = false,
  });

  @override
  Widget build(BuildContext context) {
    final todayPos = timetable.type.locate(DateTime.now());
    final cellSize = Size(fullSize.width / 7.62, fullSize.height / 11);
    final timetableWeek = timetable.getWeek(weekIndex);

    final view = buildSingleWeekView(
      timetableWeek,
      context: context,
      cellSize: cellSize,
      fullSize: fullSize,
      todayPos: todayPos,
      timetable: timetable,
    );
    if (showFreeTip && timetableWeek.isFree) {
      // free week
      return [
        view,
        FreeWeekTip(
          timetable: timetable,
          weekIndex: weekIndex,
        ).padOnly(t: fullSize.height * 0.2),
      ].stack();
    } else {
      return view;
    }
  }

  /// timeslots
  Widget buildLeftColumn(
    BuildContext context,
    Size cellSize, {
    required int month,
  }) {
    final textStyle = context.textTheme.bodyMedium;
    final cells = <Widget>[];
    cells.add(Container(
      color: getTimetableHeaderColor(context),
      child: SizedBox(
        width: cellSize.width * 0.6,
        child: MonthHeaderCellTextBox(
          month: month,
        ),
      ),
    ));
    for (var i = 0; i < 11; i++) {
      cells.add(DashLined(
        color: getTimetableHeaderDashLinedColor(context),
        top: true,
        child: Container(
          color: getTimetableHeaderColor(context),
          child: SizedBox.fromSize(
            size: Size(cellSize.width * 0.6, cellSize.height),
            child: (i + 1).toString().text(style: textStyle).center(),
          ),
        ),
      ));
    }
    return cells.column();
  }

  Widget buildSingleWeekView(
    TimetableWeek timetableWeek, {
    required BuildContext context,
    required TimetableEntity timetable,
    required Size cellSize,
    required Size fullSize,
    required TimetablePos todayPos,
  }) {
    return List.generate(8, (index) {
      if (index == 0) {
        return buildLeftColumn(context, cellSize,
            month: reflectWeekDayIndexToDate(
              weekIndex: weekIndex,
              weekday: Weekday.monday,
              startDate: timetable.startDate,
            ).month);
      } else {
        return _buildCellsByDay(
          context,
          timetableWeek.days[index - 1],
          cellSize,
          todayPos: todayPos,
        );
      }
    }).row();
  }

  /// lessons on a day
  Widget _buildCellsByDay(
    BuildContext context,
    TimetableDay day,
    Size cellSize, {
    required TimetablePos todayPos,
  }) {
    final cells = <Widget>[];
    cells.add(DashLined(
      color: getTimetableHeaderDashLinedColor(context),
      child: Container(
        width: cellSize.width,
        color: getTimetableHeaderColor(
          context,
          selected: todayPos.weekIndex == weekIndex && todayPos.weekday == day.weekday,
        ),
        child: HeaderCellTextBox(
          weekIndex: weekIndex,
          weekday: day.weekday,
          startDate: timetable.type.startDate,
        ),
      ),
    ));
    for (int timeslot = 0; timeslot < day.timeslot2LessonSlot.length; timeslot++) {
      final lessonSlot = day.timeslot2LessonSlot[timeslot];

      /// TODO: Multi-layer lesson slot
      final lesson = lessonSlot.lessonAt(0);
      if (lesson == null) {
        cells.add(DashLined(
          color: getTimetableHeaderDashLinedColor(context),
          top: true,
          strokeWidth: 0.5,
          child: SizedBox(width: cellSize.width, height: cellSize.height),
        ));
      } else {
        /// TODO: Range checking
        final course = lesson.course;
        cells.add(DashLined(
          color: getTimetableHeaderDashLinedColor(context),
          top: true,
          child: SizedBox(
            width: cellSize.width,
            height: cellSize.height * lesson.type.timeslotDuration,
            child: cellBuilder(
              context: context,
              lesson: lesson,
              timetable: timetable,
            ),
          ),
        ));

        /// Skip to the end
        timeslot = lesson.type.endIndex;
      }
    }

    return cells.column();
  }
}

class InteractiveCourseCell extends ConsumerWidget {
  final TimetableLessonPart lesson;
  final TimetableEntity timetable;
  final bool isLessonTaken;
  final TimetableStyleData style;

  const InteractiveCourseCell({
    super.key,
    required this.lesson,
    required this.timetable,
    this.isLessonTaken = false,
    required this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickLookLessonOnTap = ref.watch(Settings.timetable.$quickLookLessonOnTap);
    if (quickLookLessonOnTap) {
      return InteractiveCourseCellWithTooltip(
        timetable: timetable,
        isLessonTaken: isLessonTaken,
        style: style,
        lesson: lesson,
      );
    }
    final course = lesson.course;
    return StyledCourseCell(
      timetable: timetable,
      course: course,
      isLessonTaken: isLessonTaken,
      style: style,
      innerBuilder: (ctx, child) => InkWell(
        onTap: () async {
          if (!context.mounted) return;
          await context.showSheet(
            (ctx) => TimetableCourseSheetPage(
              courseCode: course.courseCode,
              timetable: timetable,
              highlightedCourseKey: course.courseKey,
            ),
          );
        },
        child: child,
      ),
    );
  }
}

class InteractiveCourseCellWithTooltip extends StatefulWidget {
  final TimetableLessonPart lesson;
  final TimetableEntity timetable;
  final bool isLessonTaken;
  final TimetableStyleData style;

  const InteractiveCourseCellWithTooltip({
    super.key,
    required this.lesson,
    required this.timetable,
    this.isLessonTaken = false,
    required this.style,
  });

  @override
  State<InteractiveCourseCellWithTooltip> createState() => _InteractiveCourseCellWithTooltipState();
}

class _InteractiveCourseCellWithTooltipState extends State<InteractiveCourseCellWithTooltip> {
  final $tooltip = GlobalKey<TooltipState>(debugLabel: "tooltip");

  @override
  Widget build(BuildContext context) {
    return StyledCourseCell(
      timetable: widget.timetable,
      course: widget.lesson.course,
      isLessonTaken: widget.isLessonTaken,
      style: widget.style,
      innerBuilder: (ctx, child) => Tooltip(
        key: $tooltip,
        preferBelow: false,
        triggerMode: UniversalPlatform.isDesktop ? TooltipTriggerMode.tap : TooltipTriggerMode.manual,
        message: buildTooltipMessage(),
        textAlign: TextAlign.center,
        child: InkWell(
          onTap: UniversalPlatform.isDesktop
              ? null
              : () async {
                  $tooltip.currentState?.ensureTooltipVisible();
                  await HapticFeedback.selectionClick();
                },
          // onDoubleTap: showDetailsSheet,
          onLongPress: showDetailsSheet,
          child: child,
        ),
      ),
    );
  }

  Future<void> showDetailsSheet() async {
    final course = widget.lesson.course;
    await context.showSheet(
      (ctx) => TimetableCourseSheetPage(
        courseCode: course.courseCode,
        timetable: widget.timetable,
        highlightedCourseKey: course.courseKey,
      ),
    );
  }

  String buildTooltipMessage() {
    final course = widget.lesson.course;
    final classTimes = calcBeginEndTimePointForEachLesson(course.timeslots, widget.timetable.campus, course.place);
    final lessonTimeTip = classTimes.map((time) => "${time.begin.l10n(context)}–${time.end.l10n(context)}").join("\n");
    var tooltip = "${i18n.course.courseCode} ${course.courseCode}";
    if (course.classCode.isNotEmpty) {
      tooltip += "\n${i18n.course.classCode} ${course.classCode}";
    }
    tooltip += "\n$lessonTimeTip";
    return tooltip;
  }
}

class CourseCell extends StatelessWidget {
  final String courseName;
  final String place;
  final List<String>? teachers;
  final Widget Function(BuildContext context, Widget child)? innerBuilder;
  final Color color;
  final Color? textColor;

  const CourseCell({
    super.key,
    required this.courseName,
    required this.color,
    required this.place,
    this.teachers,
    this.innerBuilder,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final innerBuilder = this.innerBuilder;
    final info = TimetableSlotInfo(
      courseName: courseName,
      maxLines: context.isPortrait ? 8 : 5,
      place: place,
      teachers: teachers,
      textColor: textColor,
    ).center();
    return Card.filled(
      clipBehavior: Clip.hardEdge,
      color: color,
      margin: const EdgeInsets.all(0.5),
      child: innerBuilder != null ? innerBuilder(context, info) : info,
    );
  }
}

class StyledCourseCell extends StatelessWidget {
  final Course course;
  final TimetableEntity timetable;
  final bool isLessonTaken;
  final Widget Function(BuildContext context, Widget child)? innerBuilder;
  final TimetableStyleData style;

  const StyledCourseCell({
    super.key,
    required this.timetable,
    required this.course,
    required this.isLessonTaken,
    required this.style,
    this.innerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorEntry = timetable.resolveColor(style.platte, course);
    var color = colorEntry.colorBy(context);
    color = style.cellStyle.decorateColor(
      color,
      themeColor: context.colorScheme.primary,
      isLessonTaken: isLessonTaken,
    );
    return CourseCell(
      courseName: course.courseName,
      color: color,
      textColor: colorEntry.textColorBy(context),
      place: course.place,
      teachers: style.cellStyle.showTeachers ? course.teachers : null,
      innerBuilder: innerBuilder,
    );
  }
}

class TimetableSlotInfo extends StatelessWidget {
  final String courseName;
  final String place;
  final List<String>? teachers;
  final int maxLines;
  final Color? textColor;

  const TimetableSlotInfo({
    super.key,
    required this.maxLines,
    required this.courseName,
    required this.place,
    this.teachers,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final teachers = this.teachers;
    return AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(
            text: courseName,
            style: context.textTheme.bodyMedium?.copyWith(
              color: textColor,
            ),
          ),
          if (place.isNotEmpty)
            TextSpan(
              text: "\n${beautifyPlace(place)}",
              style: context.textTheme.bodySmall?.copyWith(
                color: textColor,
              ),
            ),
          if (teachers != null)
            TextSpan(
              text: "\n${teachers.join(',')}",
              style: context.textTheme.bodySmall?.copyWith(
                color: textColor,
              ),
            ),
        ],
      ),
      minFontSize: 0,
      stepGranularity: 0.1,
      maxLines: maxLines,
      textAlign: TextAlign.center,
    );
  }
}
