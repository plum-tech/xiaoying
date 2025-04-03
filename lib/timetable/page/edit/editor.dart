import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/adaptive/swipe.dart';
import 'package:mimir/design/widget/card.dart';
import 'package:mimir/design/widget/expansion_tile.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/l10n/time.dart';
import 'package:mimir/school/widget/course.dart';
import 'package:mimir/settings/settings.dart';
import '../../entity/issue.dart';
import '../../widget/issue.dart';
import 'package:mimir/utils/save.dart';

import '../../entity/timetable.dart';
import '../../i18n.dart';
import 'course_editor.dart';
import '../preview.dart';

class TimetableEditorPage extends StatefulWidget {
  final Timetable timetable;

  const TimetableEditorPage({
    super.key,
    required this.timetable,
  });

  @override
  State<TimetableEditorPage> createState() => _TimetableEditorPageState();
}

class _TimetableEditorPageState extends State<TimetableEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final $name = TextEditingController(text: widget.timetable.name);
  late final $startDate = ValueNotifier(widget.timetable.startDate);
  late final $signature = TextEditingController(text: widget.timetable.signature);
  late var courses = Map.of(widget.timetable.courses);
  late var campus = widget.timetable.campus;
  late var lastCourseKey = widget.timetable.lastCourseKey;
  var navIndex = 0;
  var anyChanged = false;

  void markChanged() => anyChanged |= true;

  @override
  void initState() {
    super.initState();
    $name.addListener(() {
      if ($name.text != widget.timetable.name) {
        setState(() => markChanged());
      }
    });
    $startDate.addListener(() {
      if ($startDate.value != widget.timetable.startDate) {
        setState(() => markChanged());
      }
    });
    $signature.addListener(() {
      if ($signature.text != widget.timetable.signature) {
        setState(() => markChanged());
      }
    });
  }

  @override
  void dispose() {
    $name.dispose();
    $startDate.dispose();
    $signature.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PromptSaveBeforeQuitScope(
      changed: anyChanged,
      onSave: onSave,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: i18n.import.timetableInfo.text(),
              actions: [
                PlatformTextButton(
                  onPressed: onPreview,
                  child: i18n.preview.text(),
                ),
                PlatformTextButton(
                  onPressed: onSave,
                  child: i18n.save.text(),
                ),
              ],
            ),
            if (navIndex == 0) ...buildInfoTab() else ...buildAdvancedTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: navIndex,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.info_outline),
              selectedIcon: const Icon(Icons.info),
              label: i18n.editor.infoTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: i18n.editor.advancedTab,
            ),
          ],
          onDestinationSelected: (newIndex) {
            setState(() {
              navIndex = newIndex;
            });
          },
        ),
      ),
    );
  }

  List<Widget> buildInfoTab() {
    final timetable = buildTimetable();
    final issues = timetable.inspect();
    return [
      SliverList.list(children: [
        buildDescForm(),
        buildStartDate(),
        buildCampus(),
        buildSignature(),
        if (issues.isNotEmpty) ...[
          ListTile(
            leading: Icon(context.icons.warning),
            title: i18n.issue.title.text(),
          ),
          ...issues.build(
            context: context,
            timetable: timetable,
            onTimetableChanged: (newTimetable) {
              setFromTimetable(newTimetable);
            },
          ),
        ],
      ]),
    ];
  }

  Widget buildCampus() {
    return ListTile(
      title: i18n.course.campus.text(),
      subtitle: Campus.values
          .map((c) => ChoiceChip(
                label: c.l10n().text(),
                selected: c == campus,
                onSelected: (value) {
                  setState(() {
                    campus = c;
                  });
                },
              ))
          .toList()
          .wrap(spacing: 4),
    );
  }

  List<Widget> buildAdvancedTab() {
    final code2Courses = courses.values.groupListsBy((c) => c.courseCode).entries.toList();
    code2Courses.sortBy((p) => p.key);
    for (var p in code2Courses) {
      p.value.sortBy((l) => l.courseCode);
    }
    return [
      SliverList.list(children: [
        addCourseTile(),
        const Divider(thickness: 2),
      ]),
      SliverList.builder(
        itemCount: code2Courses.length,
        itemBuilder: (ctx, i) {
          final MapEntry(key: courseKey, value: courses) = code2Courses[i];
          final template = courses.first;
          return TimetableEditableCourseCard(
            key: ValueKey(courseKey),
            courses: courses,
            template: template,
            campus: campus,
            onCourseChanged: onCourseChanged,
            onCourseAdded: onCourseAdded,
            onCourseRemoved: onCourseRemoved,
          );
        },
      ),
    ];
  }

  Widget addCourseTile() {
    return ListTile(
      title: i18n.editor.addCourse.text(),
      trailing: Icon(context.icons.add),
      onTap: () async {
        final newCourse = await context.showSheet<Course>(
          (ctx) => SitCourseEditorPage(
            title: i18n.editor.newCourse,
            course: null,
          ),
        );
        if (newCourse == null) return;
        onCourseAdded(newCourse);
      },
    );
  }

  void onCourseChanged(Course old, Course newValue) {
    markChanged();
    final key = "${newValue.courseKey}";
    if (courses.containsKey(key)) {
      setState(() {
        courses[key] = newValue;
      });
    }
    // check if shared fields are changed.
    if (old.courseCode != newValue.courseCode ||
        old.classCode != newValue.classCode ||
        old.courseName != newValue.courseName) {
      for (final MapEntry(:key, value: course) in courses.entries.toList()) {
        if (course.courseCode == old.courseCode) {
          // change the shared fields simultaneously
          courses[key] = course.copyWith(
            courseCode: newValue.courseCode,
            classCode: newValue.classCode,
            courseName: newValue.courseName,
            hidden: newValue.hidden,
          );
        }
      }
    }
  }

  void onCourseAdded(Course course) {
    markChanged();
    course = course.copyWith(
      courseKey: lastCourseKey++,
    );
    setState(() {
      courses["${course.courseKey}"] = course;
    });
  }

  void onCourseRemoved(Course course) {
    final key = "${course.courseKey}";
    if (courses.containsKey(key)) {
      setState(() {
        courses.remove("${course.courseKey}");
      });
      markChanged();
    }
  }

  Widget buildStartDate() {
    return ListTile(
      leading: const Icon(Icons.alarm),
      title: i18n.startWith.text(),
      trailing: FilledButton(
        child: $startDate >> (ctx, value) => ctx.formatYmdText(value).text(),
        onPressed: () async {
          final date = await _pickTimetableStartDate(context, initial: $startDate.value);
          if (date != null) {
            $startDate.value = DateTime(date.year, date.month, date.day);
          }
        },
      ),
    );
  }

  Widget buildSignature() {
    return ListTile(
      isThreeLine: true,
      leading: const Icon(Icons.drive_file_rename_outline),
      title: i18n.signature.text(),
      subtitle: TextField(
        controller: $signature,
        decoration: InputDecoration(
          hintText: i18n.signaturePlaceholder,
        ),
      ),
    );
  }

  Timetable buildTimetable() {
    final signature = $signature.text.trim();
    return widget.timetable.copyWith(
      name: $name.text,
      signature: signature,
      startDate: $startDate.value,
      campus: campus,
      courses: courses,
      lastCourseKey: lastCourseKey,
      lastModified: DateTime.now(),
    );
  }

  void setFromTimetable(Timetable timetable) {
    setState(() {
      $name.text = timetable.name;
      $startDate.value = timetable.startDate;
      $signature.text = timetable.signature;
      courses = Map.of(timetable.courses);
      lastCourseKey = timetable.lastCourseKey;
    });
    markChanged();
  }

  void onSave() {
    final signature = $signature.text.trim();
    Settings.lastSignature = signature;
    final timetable = buildTimetable();
    context.pop(timetable);
  }

  Future<void> onPreview() async {
    await previewTimetable(context, timetable: buildTimetable());
  }

  Widget buildDescForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: $name,
            maxLines: 2,
            inputFormatters: [
              LengthLimitingTextInputFormatter(Timetable.maxNameLength),
              FilteringTextInputFormatter.deny("\n"),
            ],
            decoration: InputDecoration(
              labelText: i18n.editor.name,
              border: const OutlineInputBorder(),
            ),
          ).padAll(10),
        ],
      ),
    );
  }
}

Future<DateTime?> _pickTimetableStartDate(
  BuildContext ctx, {
  required DateTime initial,
}) async {
  final now = DateTime.now();
  return await showDatePicker(
    context: ctx,
    initialDate: initial,
    currentDate: now,
    firstDate: DateTime(now.year - 4),
    lastDate: DateTime(now.year + 2),
    selectableDayPredicate: (DateTime dataTime) => dataTime.weekday == DateTime.monday,
  );
}

class TimetableEditableCourseCard extends StatelessWidget {
  final Course template;
  final List<Course> courses;
  final Campus campus;
  final Color? color;
  final void Function(Course old, Course newValue)? onCourseChanged;
  final void Function(Course)? onCourseAdded;
  final void Function(Course)? onCourseRemoved;

  const TimetableEditableCourseCard({
    super.key,
    required this.template,
    required this.courses,
    this.color,
    this.onCourseChanged,
    this.onCourseAdded,
    this.onCourseRemoved,
    required this.campus,
  });

  @override
  Widget build(BuildContext context) {
    final onCourseRemoved = this.onCourseRemoved;
    final allHidden = courses.every((c) => c.hidden);
    final templateStyle = TextStyle(color: allHidden ? context.theme.disabledColor : null);
    return AnimatedExpansionTile(
      leading: CourseIcon(
        courseName: template.courseName,
        enabled: !allHidden,
      ),
      visualDensity: VisualDensity.compact,
      rotateTrailing: false,
      title: template.courseName.text(style: templateStyle),
      subtitle: [
        if (template.courseCode.isNotEmpty)
          "${i18n.course.courseCode} ${template.courseCode}".text(style: templateStyle),
        if (template.classCode.isNotEmpty) "${i18n.course.classCode} ${template.classCode}".text(style: templateStyle),
      ].column(caa: CrossAxisAlignment.start),
      trailing: [
        PlatformIconButton(
          icon: Icon(context.icons.add),
          padding: EdgeInsets.zero,
          onPressed: () async {
            final tempItem = template.createSubItem(courseKey: 0);
            final newItem = await context.showSheet(
              (context) => SitCourseEditorPage(
                title: i18n.editor.newCourse,
                course: tempItem,
                editable: const SitCourseEditable.item(),
              ),
            );
            if (newItem == null) return;
            onCourseAdded?.call(newItem);
          },
        ),
        PlatformIconButton(
          icon: Icon(context.icons.edit),
          padding: EdgeInsets.zero,
          onPressed: () async {
            final newTemplate = await context.showSheet<Course>(
              (context) => SitCourseEditorPage(
                title: i18n.editor.editCourse,
                editable: const SitCourseEditable.template(),
                course: template,
              ),
            );
            if (newTemplate == null) return;
            onCourseChanged?.call(template, newTemplate);
          },
        ),
      ].row(mas: MainAxisSize.min),

      // sub-courses
      children: courses.mapIndexed((i, course) {
        final weekNumbers = course.weekIndices.l10n();
        final (:begin, :end) = calcBeginEndTimePoint(course.timeslots, campus, course.place);
        return WithSwipeAction(
          childKey: ValueKey(course.courseKey),
          right: onCourseRemoved == null
              ? null
              : SwipeAction.delete(
                  icon: context.icons.delete,
                  action: () async {
                    onCourseRemoved(course);
                  },
                ),
          child: ListTile(
            isThreeLine: true,
            visualDensity: VisualDensity.compact,
            enabled: !course.hidden,
            title: course.place.text(),
            subtitle: [
              course.teachers.join(", ").text(),
              "${Weekday.fromIndex(course.dayIndex).l10n()} ${begin.l10n(context)}–${end.l10n(context)}".text(),
              ...weekNumbers.map((n) => n.text()),
            ].column(mas: MainAxisSize.min, caa: CrossAxisAlignment.start),
            trailing: PlatformIconButton(
              icon: Icon(context.icons.edit),
              padding: EdgeInsets.zero,
              onPressed: () async {
                final newItem = await context.showSheet<Course>(
                  (context) => SitCourseEditorPage(
                    title: i18n.editor.editCourse,
                    course: course,
                    editable: const SitCourseEditable.item(),
                  ),
                );
                if (newItem == null) return;
                onCourseChanged?.call(course, newItem);
              },
            ),
          ),
        );
      }).toList(),
    ).inAnyCard(
      clip: Clip.hardEdge,
      type: allHidden ? CardVariant.outlined : CardVariant.filled,
      color: allHidden ? null : color,
    );
  }
}

extension _SitCourseX on Course {
  Course createSubItem({
    required int courseKey,
  }) {
    return Course(
      courseKey: courseKey,
      courseName: courseName,
      courseCode: courseCode,
      classCode: classCode,
      place: "",
      weekIndices: const TimetableWeekIndices([]),
      timeslots: (start: 0, end: 0),
      courseCredit: courseCredit,
      dayIndex: 0,
      teachers: teachers,
    );
  }
}
