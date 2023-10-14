import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/design/widgets/duration_picker.dart';
import '../entity/timetable.dart';
import "../i18n.dart";

typedef TimetableExportCalendarAlarmConfig = ({
  Duration alarmBeforeClass,
  Duration alarmDuration,
  bool isSoundAlarm,
});

typedef TimetableExportCalendarConfig = ({
  TimetableExportCalendarAlarmConfig? alarm,
  Locale? locale,
  bool isLessonMerged,
});

class TimetableExportCalendarConfigEditor extends StatefulWidget {
  final SitTimetable timetable;

  const TimetableExportCalendarConfigEditor({
    super.key,
    required this.timetable,
  });

  @override
  State<TimetableExportCalendarConfigEditor> createState() => _TimetableExportCalendarConfigEditorState();
}

class _TimetableExportCalendarConfigEditorState extends State<TimetableExportCalendarConfigEditor> {
  final $enableAlarm = ValueNotifier(false);
  final $alarmDuration = ValueNotifier(const Duration(minutes: 15));
  final $alarmBeforeClass = ValueNotifier(const Duration(minutes: 15));
  final $merged = ValueNotifier(true);
  final $isSoundAlarm = ValueNotifier(false);

  @override
  void dispose() {
    $enableAlarm.dispose();
    $alarmDuration.dispose();
    $alarmBeforeClass.dispose();
    $merged.dispose();
    $isSoundAlarm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: i18n.export.title.text(),
            actions: [
              buildExportAction(),
            ],
          ),
          SliverList.list(children: [
            buildModeSwitch(),
            const Divider(),
            buildAlarmToggle(),
            buildAlarmModeSwitch(),
            buildAlarmDuration(),
            buildAlarmBeforeClassStart(),
          ]),
        ],
      ),
    );
  }

  Widget buildExportAction() {
    return CupertinoButton(
      child: i18n.export.export.text(),
      onPressed: () async {
        context.pop<TimetableExportCalendarConfig>((
          alarm: $enableAlarm.value
              ? (
                  alarmBeforeClass: $alarmBeforeClass.value,
                  alarmDuration: $alarmDuration.value,
                  isSoundAlarm: $isSoundAlarm.value,
                )
              : null,
          locale: context.locale,
          isLessonMerged: $merged.value,
        ));
      },
    );
  }

  Widget buildModeSwitch() {
    return $merged >>
        (ctx, merged) => ListTile(
              title: i18n.export.lessonMode.text(),
              leading: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: merged ? i18n.export.lessonModeMergedInfo : i18n.export.lessonModeSeparateInfo,
                child: Icon(Icons.info_outline, color: context.colorScheme.primary),
              ),
              subtitle: i18n.export.lessonModeDesc.text(),
              trailing: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment<bool>(
                    value: true,
                    label: i18n.export.lessonModeMerged.text(),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: i18n.export.lessonModeSeparate.text(),
                  ),
                ],
                selected: <bool>{merged},
                onSelectionChanged: (newSelection) async {
                  $merged.value = newSelection.first;
                  await HapticFeedback.selectionClick();
                },
              ),
            );
  }

  Widget buildAlarmToggle() {
    return ListTile(
      leading: const Icon(Icons.alarm),
      title: i18n.export.enableAlarm.text(),
      subtitle: i18n.export.enableAlarmDesc.text(),
      trailing: $enableAlarm >>
          (ctx, value) => Switch(
                value: value,
                onChanged: (newV) {
                  $enableAlarm.value = newV;
                },
              ),
    );
  }

  Widget buildAlarmModeSwitch() {
    return $enableAlarm >>
        (ctx, enabled) => ListTile(
              enabled: enabled,
              title: i18n.export.enableAlarm.text(),
              subtitle: i18n.export.alarmModeDesc.text(),
              trailing: $isSoundAlarm >>
                  (ctx, value) => SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment<bool>(
                            value: true,
                            label: i18n.export.alarmModeSound.text(),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: i18n.export.alarmModeDisplay.text(),
                          ),
                        ],
                        selected: <bool>{value},
                        onSelectionChanged: !enabled
                            ? null
                            : (newSelection) async {
                                $isSoundAlarm.value = newSelection.first;
                                await HapticFeedback.selectionClick();
                              },
                      ),
            );
  }

  Widget buildAlarmDuration() {
    return $enableAlarm >>
        (ctx, enabled) =>
            $alarmDuration >>
            (ctx, duration) => ListTile(
                  enabled: enabled,
                  title: i18n.export.alarmDuration.text(),
                  subtitle: i18n.time.minuteFormat(duration.inMinutes.toString()).text(),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: !enabled
                        ? null
                        : () async {
                            final newDuration = await showDurationPicker(
                              context: ctx,
                              initialTime: duration,
                            );
                            if (newDuration != null) {
                              $alarmDuration.value = newDuration;
                            }
                          },
                  ),
                );
  }

  Widget buildAlarmBeforeClassStart() {
    return $enableAlarm >>
        (ctx, enabled) =>
            $alarmBeforeClass >>
            (ctx, duration) => ListTile(
                  enabled: enabled,
                  title: i18n.export.alarmBeforeClassBegins.text(),
                  subtitle: i18n.export.alarmBeforeClassBeginsDesc(duration).text(),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: !enabled
                        ? null
                        : () async {
                            final newDuration = await showDurationPicker(
                              context: ctx,
                              initialTime: duration,
                            );
                            if (newDuration != null) {
                              $alarmBeforeClass.value = newDuration;
                            }
                          },
                  ),
                );
  }
}
