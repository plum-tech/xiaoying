import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/design/adaptive/menu.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/animation/progress.dart';
import 'package:mimir/design/entity/dual_color.dart';
import 'package:mimir/design/widget/common.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/design/widget/entry_card.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:mimir/route.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/timetable/widget/course.dart';
import 'package:mimir/utils/format.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:uuid/uuid.dart';

import '../p13n/builtin.dart';
import '../p13n/entity/palette.dart';
import '../i18n.dart';
import '../entity/timetable.dart';
import '../init.dart';
import '../utils/export.dart';
import '../utils/freshman.dart';
import '../utils/import.dart';
import '../widget/focus.dart';
import '../p13n/widget/style.dart';
import 'import.dart';
import 'preview.dart';

class MyTimetableListPage extends ConsumerStatefulWidget {
  const MyTimetableListPage({super.key});

  @override
  ConsumerState<MyTimetableListPage> createState() => _MyTimetableListPageState();
}

class _MyTimetableListPageState extends ConsumerState<MyTimetableListPage> {
  String? syncingUuid;

  @override
  Widget build(BuildContext context) {
    final storage = TimetableInit.storage.timetable;
    final timetables = ref.watch(storage.$rows);
    final selectedId = ref.watch(storage.$selectedId);
    timetables.sort((a, b) => b.lastModified.compareTo(a.lastModified));

    if (timetables.isEmpty) {
      return buildEmptyTimetableBody();
    } else {
      return buildTimetablesBody(
        timetables: timetables,
        selectedId: selectedId,
      );
    }
  }

  Widget buildFab() {
    return FloatingActionButton.extended(
      onPressed: goImport,
      label: Text(isLoginGuarded(context) ? i18n.import.fromFile : i18n.import.import),
      icon: Icon(context.icons.add),
    );
  }

  Widget buildEmptyTimetableBody() {
    return Scaffold(
      appBar: AppBar(
        title: i18n.mine.title.text(),
        actions: [
          buildMoreActionsButton(),
        ],
      ),
      floatingActionButton: buildFab(),
      body: LeavingBlank(
        icon: Icons.calendar_month_rounded,
        desc: i18n.mine.emptyTip,
        action: FilledButton(
          onPressed: goImport,
          child: i18n.import.import.text(),
        ),
      ),
    );
  }

  Widget buildTimetablesBody({
    required List<Timetable> timetables,
    required String? selectedId,
  }) {
    final timetableNames = timetables.map((t) => t.name).toList();
    return Scaffold(
      floatingActionButton: buildFab(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: i18n.mine.title.text(),
          ),
          SliverList.builder(
            itemCount: timetables.length,
            itemBuilder: (ctx, i) {
              final timetable = timetables[i];
              return BlockWhenLoading(
                blocked: syncingUuid != null,
                loading: timetable.uuid == syncingUuid,
                child: buildCard(
                  timetable: timetable,
                  selectedId: selectedId,
                  timetableNames: timetableNames,
                ),
              ).padH(6);
            },
          ),
          const SizedBox(height: 80).sliver(),
        ],
      ),
    );
  }

  Widget buildCard({
    required Timetable timetable,
    required String? selectedId,
    required List<String> timetableNames,
  }) {
    return TimetableCard(
      timetable: timetable,
      selected: selectedId == timetable.uuid,
      allTimetableNames: timetableNames,
    );
  }

  /// Import a new timetable.
  /// Updates the selected timetable id.
  /// If [TimetableSettings.autoUseImported] is enabled, the newly-imported will be used.
  Future<void> goImport() async {
    Timetable? timetable;
    final fromFile = isLoginGuarded(context);
    if (fromFile) {
      timetable = await importFromFile();
    } else {
      timetable = await importFromSchoolServer();
    }
    if (timetable == null) return;
    // process timetable imported from file
    // if (fromFile) {
    //   if (!mounted) return;
    //   final newTimetable = await processImportedTimetable(context, timetable);
    //   if (newTimetable == null) return;
    //   timetable = newTimetable;
    // }

    // prevent duplicate names
    // timetable = timetable.copyWith(
    //   name: allocValidFileName(
    //     timetable.name,
    //     all: TimetableInit.storage.timetable.getRows().map((e) => e.row.name).toList(growable: false),
    //   ),
    // );
    final id = TimetableInit.storage.timetable.add(timetable);

    if (Settings.timetable.autoUseImported) {
      TimetableInit.storage.timetable.selectedId = id;
    } else {
      // use this timetable if no one else
      TimetableInit.storage.timetable.selectedId ??= id;
    }
  }

  Future<Timetable?> importFromSchoolServer() async {
    if (ref.read(CredentialsInit.storage.oa.$userType) == OaUserType.freshman) {
      await onFreshmanImport(context);
      return null;
    }
    return await context.push<Timetable>("/timetable/import");
  }

  Future<Timetable?> importFromFile() async {
    final timetable = await readTimetableFromPickedFileWithPrompt(context);
    if (timetable == null) return null;
    if (!mounted) return null;
    return timetable;
  }

  Widget buildMoreActionsButton() {
    return PullDownMenuButton(
      itemBuilder: (ctx) => [
        PullDownItem(
          icon: Icons.view_comfortable_outlined,
          title: i18n.p13n.cell.title,
          onTap: () async {
            await context.push("/timetable/cell-style");
          },
        ),
        ...buildFocusPopupActions(context),
      ],
    );
  }
}

class TimetableCard extends StatelessWidget {
  final Timetable timetable;
  final bool selected;
  final List<String>? allTimetableNames;

  const TimetableCard({
    super.key,
    required this.timetable,
    required this.selected,
    this.allTimetableNames,
  });

  @override
  Widget build(BuildContext context) {
    return EntryCard(
      title: timetable.name,
      selected: selected,
      selectAction: (ctx) => EntrySelectAction(
        selectLabel: i18n.use,
        selectedLabel: i18n.used,
        action: () async {
          TimetableInit.storage.timetable.selectedId = timetable.uuid;
        },
      ),
      deleteAction: (ctx) => EntryAction.delete(
        label: i18n.delete,
        icon: context.icons.delete,
        action: () async {
          final confirm = await ctx.showActionRequest(
            title: i18n.mine.deleteRequest,
            action: i18n.delete,
            desc: i18n.mine.deleteRequestDesc,
            cancel: i18n.cancel,
            destructive: true,
          );
          if (confirm != true) return;
          TimetableInit.storage.timetable.delete(timetable.uuid);
          if (TimetableInit.storage.timetable.isEmpty) {
            if (!ctx.mounted) return;
            ctx.pop();
          }
        },
      ),
      actions: (ctx) => [
        if (!selected)
          EntryAction(
            main: true,
            label: i18n.preview,
            icon: ctx.icons.preview,
            activator: const SingleActivator(LogicalKeyboardKey.keyP),
            action: () async {
              if (!ctx.mounted) return;
              await previewTimetable(
                context,
                timetable: timetable,
              );
            },
          ),
        EntryAction.edit(
          label: i18n.edit,
          icon: context.icons.edit,
          activator: const SingleActivator(LogicalKeyboardKey.keyE),
          action: () async {
            var newTimetable = await ctx.push<Timetable>("/timetable/edit/${timetable.uuid}");
            if (newTimetable == null) return;
            final newName = allocValidFileName(newTimetable.name);
            if (newName != newTimetable.name) {
              newTimetable = newTimetable.copyWith(name: newName);
            }
            TimetableInit.storage.timetable[timetable.uuid] = newTimetable.markModified();
          },
        ),
        // share_plus: sharing files is not supported on Linux
        if (!UniversalPlatform.isLinux)
          EntryAction(
            label: i18n.share,
            icon: context.icons.share,
            type: EntryActionType.share,
            action: () async {
              await exportTimetableFileAndShare(timetable, context: ctx);
            },
          ),
        if (kDebugMode)
          EntryAction(
            icon: context.icons.copy,
            label: "Copy Dart code",
            action: () async {
              final code = timetable.toDartCode();
              debugPrint(code);
              await Clipboard.setData(ClipboardData(text: code));
            },
          ),
        EntryAction(
          label: i18n.duplicate,
          oneShot: true,
          icon: context.icons.copy,
          activator: const SingleActivator(LogicalKeyboardKey.keyD),
          action: () async {
            final duplicate = timetable.copyWith(
              uuid: const Uuid().v4(),
              name: getDuplicateFileName(timetable.name, all: allTimetableNames),
              lastModified: DateTime.now(),
            );
            TimetableInit.storage.timetable.add(duplicate);
          },
        ),
      ],
      detailsBuilder: (ctx, actions) {
        return TimetableStyleProv(
          child: TimetableDetailsPage(
            timetable: timetable,
            actions: actions?.call(ctx),
          ),
        );
      },
      itemBuilder: (ctx) {
        return TimetableInfo(timetable: timetable);
      },
    );
  }
}

class TimetableInfo extends StatelessWidget {
  final Timetable timetable;

  const TimetableInfo({
    super.key,
    required this.timetable,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final year = '${timetable.schoolYear}–${timetable.schoolYear + 1}';
    final semester = timetable.semester.l10n();
    final author = [timetable.studentId, timetable.signature].join(" ");
    return [
      timetable.name.text(style: textTheme.titleLarge),
      "$year, $semester".text(style: textTheme.titleMedium),
      if (author.isNotEmpty) author.text(style: textTheme.bodyMedium),
      "${i18n.startWith} ${context.formatYmdText(timetable.startDate)}".text(style: textTheme.bodyMedium),
    ].column(caa: CrossAxisAlignment.start);
  }
}

class TimetableDetailsPage extends ConsumerWidget {
  final Timetable timetable;
  final List<Widget>? actions;

  const TimetableDetailsPage({
    super.key,
    required this.timetable,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetable = ref.watch(TimetableInit.storage.timetable.$rowOf(this.timetable.uuid)) ?? this.timetable;
    final resolver = TimetablePaletteResolver(timetable);
    final palette = ref.watch(TimetableInit.storage.palette.$selectedRow) ?? BuiltinTimetablePalettes.classic;
    final code2Courses = timetable.courses.values.groupListsBy((c) => c.courseCode).entries.toList();
    final style = TimetableStyle.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: TextScroll(timetable.name),
            actions: actions,
          ),
          SliverList.list(children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: i18n.editor.name.text(),
              subtitle: timetable.name.text(),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: i18n.startWith.text(),
              subtitle: context.formatYmdText(timetable.startDate).text(),
            ),
            ListTile(
              leading: const Icon(Icons.create),
              title: i18n.createdWhen.text(),
              subtitle: context.formatYmdText(timetable.createdTime).text(),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: i18n.signature.text(),
              subtitle: timetable.signature.text(),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: StudentType.l10nTitle().text(),
              subtitle: timetable.studentType.l10n().text(),
            ),
          ]),
          if (code2Courses.isNotEmpty) const SliverToBoxAdapter(child: Divider()),
          SliverList.builder(
            itemCount: code2Courses.length,
            itemBuilder: (ctx, i) {
              final MapEntry(value: courses) = code2Courses[i];
              final template = courses.first;
              final color = resolver.resolveColor(palette, template).colorBy(context);
              return TimetableCourseCard(
                courses: courses,
                courseName: template.courseName,
                courseCode: template.courseCode,
                classCode: template.classCode,
                campus: timetable.campus,
                color: style.cellStyle.decorateColor(color, themeColor: ctx.colorScheme.primary),
              );
            },
          )
        ],
      ),
    );
  }
}

Future<void> onTimetableFromFile({
  required BuildContext context,
  required Timetable timetable,
}) async {
  final newTimetable = await processImportedTimetable(
    context,
    timetable,
    useRootNavigator: true,
  );
  if (newTimetable == null) return;
  final id = TimetableInit.storage.timetable.add(timetable);
  if (Settings.timetable.autoUseImported) {
    TimetableInit.storage.timetable.selectedId = id;
  } else {
    TimetableInit.storage.timetable.selectedId ??= id;
  }
  await HapticFeedback.mediumImpact();
  if (!context.mounted) return;
  context.push("/timetable/mine");
}
