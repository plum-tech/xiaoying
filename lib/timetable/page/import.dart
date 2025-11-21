import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/school/widget/semester.dart';
import 'package:rettulf/rettulf.dart';

import '../i18n.dart';
import '../entity/timetable.dart';
import '../utils/import.dart';
import 'edit/editor.dart';

/// It doesn't persist changes to storage before route popping.
class ImportTimetablePage extends ConsumerStatefulWidget {
  const ImportTimetablePage({super.key});

  @override
  ConsumerState<ImportTimetablePage> createState() => _ImportTimetablePageState();
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
        title: i18n.import.title.text(),
        actions: [
          PlatformTextButton(
            onPressed: importFromFile,
            child: i18n.import.fromFileBtn.text(),
          ),
        ],
      ),
      body: buildImportPage(),
    );
  }

  Future<void> importFromFile() async {
    var timetable = await readTimetableFromPickedFileWithPrompt(context);
    if (timetable == null) return;
    if (!mounted) return;
    timetable = await processImportedTimetable(context, timetable);
    if (timetable == null) return;
    if (!mounted) return;
    context.pop(timetable);
  }

  Widget buildImportPage({Key? key}) {
    final credentials = ref.watch(CredentialsInit.storage.oa.$credentials);
    return [
      SemesterSelector(
        baseYear: getAdmissionYearFromStudentId(credentials?.account),
        initial: initial,
        showNextYear: true,
        onSelected: (newSelection) {
          setState(() {
            selected = newSelection;
          });
        },
      ).padSymmetric(v: 30),
    ].column(key: key, maa: MainAxisAlignment.center, caa: CrossAxisAlignment.center);
  }
}

Future<Timetable?> processImportedTimetable(
  BuildContext context,
  Timetable timetable, {
  bool useRootNavigator = false,
}) async {
  final newTimetable = await context.showSheet<Timetable>(
    (ctx) => TimetableEditorPage(
      timetable: timetable,
    ),
    dismissible: false,
  );
  return newTimetable;
}
