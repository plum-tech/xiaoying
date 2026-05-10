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
import 'package:rettulf/rettulf.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/utils/date.dart';
import 'package:mimir/utils/save.dart';
import 'package:mimir/utils/weekday.dart';

import '../../entity/timetable.dart';
import 'course_editor.dart';
import '../preview.dart';

class TimetableEditorPage extends StatefulWidget {
  final Timetable timetable;

  const TimetableEditorPage({super.key, required this.timetable});

  @override
  State<TimetableEditorPage> createState() => _TimetableEditorPageState();
}

class _TimetableEditorPageState extends State<TimetableEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final $name = TextEditingController(text: widget.timetable.name);
  late final $startDate = ValueNotifier(widget.timetable.startDate);
  late final $signature = TextEditingController(
    text: widget.timetable.signature,
  );
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
              title: "课程表信息".text(),
              actions: [
                PlatformTextButton(onPressed: onPreview, child: "预览".text()),
                PlatformTextButton(onPressed: onSave, child: "保存".text()),
              ],
            ),
            if (navIndex == 0) ...buildInfoTab() else ...buildAdvancedTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: navIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.info_outline),
              selectedIcon: Icon(Icons.info),
              label: "信息",
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: "高级",
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
    return [
      SliverList.list(
        children: [
          buildDescForm(),
          buildStartDate(),
          buildCampus(),
          buildSignature(),
        ],
      ),
    ];
  }

  Widget buildCampus() {
    return ListTile(
      title: "校区".text(),
      subtitle: Campus.values
          .map(
            (c) => ChoiceChip(
              label: c.label.text(),
              selected: c == campus,
              onSelected: (value) {
                setState(() {
                  campus = c;
                });
              },
            ),
          )
          .toList()
          .wrap(spacing: 4),
    );
  }

  List<Widget> buildAdvancedTab() {
    final code2Courses = courses.values
        .groupListsBy((c) => c.courseCode)
        .entries
        .toList();
    code2Courses.sortBy((p) => p.key);
    for (var p in code2Courses) {
      p.value.sortBy((l) => l.courseCode);
    }
    return [
      SliverList.list(children: [addCourseTile(), const Divider(thickness: 2)]),
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
      title: "添加一个课程".text(),
      trailing: Icon(context.icons.add),
      onTap: () async {
        final newCourse = await context.showSheet<Course>(
          (ctx) => const SitCourseEditorPage(title: "创建课程", course: null),
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
    course = course.copyWith(courseKey: lastCourseKey++);
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
      title: "起始于".text(),
      trailing: FilledButton(
        child: $startDate >> (ctx, value) => formatChineseDate(value).text(),
        onPressed: () async {
          final date = await _pickTimetableStartDate(
            context,
            initial: $startDate.value,
          );
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
      title: "签名".text(),
      subtitle: TextField(
        controller: $signature,
        decoration: const InputDecoration(hintText: "你的名字"),
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
            decoration: const InputDecoration(
              labelText: "名称",
              border: OutlineInputBorder(),
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
    selectableDayPredicate: (DateTime dataTime) =>
        dataTime.weekday == DateTime.monday,
  );
}

class TimetableEditableCourseCard extends StatelessWidget {
  final Course template;
  final List<Course> courses;
  final Campus campus;
  final void Function(Course old, Course newValue)? onCourseChanged;
  final void Function(Course)? onCourseAdded;
  final void Function(Course)? onCourseRemoved;

  const TimetableEditableCourseCard({
    super.key,
    required this.template,
    required this.courses,
    this.onCourseChanged,
    this.onCourseAdded,
    this.onCourseRemoved,
    required this.campus,
  });

  @override
  Widget build(BuildContext context) {
    final onCourseRemoved = this.onCourseRemoved;
    final allHidden = courses.every((c) => c.hidden);
    final templateStyle = TextStyle(
      color: allHidden ? context.theme.disabledColor : null,
    );
    return AnimatedExpansionTile(
      visualDensity: VisualDensity.compact,
      rotateTrailing: false,
      title: template.courseName.text(style: templateStyle),
      subtitle: [
        if (template.courseCode.isNotEmpty)
          "课程代码 ${template.courseCode}".text(style: templateStyle),
        if (template.classCode.isNotEmpty)
          "教学班 ${template.classCode}".text(style: templateStyle),
      ].column(caa: CrossAxisAlignment.start),
      trailing: [
        PlatformIconButton(
          icon: Icon(context.icons.add),
          padding: EdgeInsets.zero,
          onPressed: () async {
            final tempItem = template.createSubItem(courseKey: 0);
            final newItem = await context.showSheet(
              (context) => SitCourseEditorPage(
                title: "创建课程",
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
                title: "编辑课程",
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
        final weekNumbers = course.weekIndices.labels;
        final (:begin, :end) = calcBeginEndTimePoint(
          course.timeslots,
          campus,
          course.place,
        );
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
              "${Weekday.fromIndex(course.dayIndex).label} ${begin.label}–${end.label}"
                  .text(),
              ...weekNumbers.map((n) => n.text()),
            ].column(mas: MainAxisSize.min, caa: CrossAxisAlignment.start),
            trailing: PlatformIconButton(
              icon: Icon(context.icons.edit),
              padding: EdgeInsets.zero,
              onPressed: () async {
                final newItem = await context.showSheet<Course>(
                  (context) => SitCourseEditorPage(
                    title: "编辑课程",
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
    );
  }
}

extension _SitCourseX on Course {
  Course createSubItem({required int courseKey}) {
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
