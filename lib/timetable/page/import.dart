import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/school/widget/semester.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/timetable.dart';
import '../utils/import.dart';
import 'edit/editor.dart';

/// It doesn't persist changes to storage before route popping.
class ImportTimetablePage extends ConsumerStatefulWidget {
  const ImportTimetablePage({super.key});

  @override
  ConsumerState<ImportTimetablePage> createState() =>
      _ImportTimetablePageState();
}

class _ImportTimetablePageState extends ConsumerState<ImportTimetablePage> {
  late SemesterInfo initial = estimateSemesterInfo();
  late SemesterInfo selected = initial;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "导入课程表".text(),
        actions: [
          PlatformTextButton(
            onPressed: importSampleTimetable,
            child: "导入示例课程表".text(),
          ),
        ],
      ),
      body: buildImportPage(),
    );
  }

  Future<void> importSampleTimetable() async {
    var timetable = await readSampleTimetableWithPrompt(
      context,
      semesterInfo: selected,
    );
    if (timetable == null) return;
    if (!mounted) return;
    timetable = await processImportedTimetable(context, timetable);
    if (timetable == null) return;
    if (!mounted) return;
    context.pop(timetable);
  }

  Widget buildImportPage({Key? key}) {
    return [
      SemesterSelector(
        baseYear: null,
        initial: initial,
        showNextYear: true,
        onSelected: (newSelection) {
          setState(() {
            selected = newSelection;
          });
        },
      ).padSymmetric(v: 30),
    ].column(
      key: key,
      maa: MainAxisAlignment.center,
      caa: CrossAxisAlignment.center,
    );
  }
}

Future<Timetable?> processImportedTimetable(
  BuildContext context,
  Timetable timetable, {
  bool useRootNavigator = false,
}) async {
  final newTimetable = await context.showSheet<Timetable>(
    (ctx) => TimetableEditorPage(timetable: timetable),
    dismissible: false,
  );
  return newTimetable;
}
