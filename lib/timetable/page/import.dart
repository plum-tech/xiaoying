import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:mimir/design/animation/animated.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/school/widget/semester.dart';
import 'package:mimir/settings/meta.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/timetable/utils.dart';
import 'package:mimir/utils/error.dart';
import 'package:rettulf/rettulf.dart';

import '../i18n.dart';
import '../entity/timetable.dart';
import '../init.dart';
import '../utils/freshman.dart';
import '../utils/import.dart';
import 'edit/editor.dart';

enum ImportStatus {
  none,
  importing,
  end,
  failed;
}

/// It doesn't persist changes to storage before route popping.
class ImportTimetablePage extends ConsumerStatefulWidget {
  const ImportTimetablePage({super.key});

  @override
  ConsumerState<ImportTimetablePage> createState() => _ImportTimetablePageState();
}

class _ImportTimetablePageState extends ConsumerState<ImportTimetablePage> {
  var _status = ImportStatus.none;
  late SemesterInfo initial = estimateSemesterInfo();
  late SemesterInfo selected = initial;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isImporting = _status == ImportStatus.importing;
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
      floatingActionButton: !isImporting ? null : const CircularProgressIndicator.adaptive(),
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

  Widget buildTip(BuildContext ctx) {
    final tip = switch (_status) {
      ImportStatus.none => i18n.import.selectSemesterTip,
      ImportStatus.importing => i18n.import.importing,
      ImportStatus.end => i18n.import.endTip,
      ImportStatus.failed => i18n.import.failedTip,
    };
    return tip
        .text(
          key: ValueKey(_status),
          style: ctx.textTheme.titleLarge,
        )
        .animatedSwitched();
  }

  Widget buildImportPage({Key? key}) {
    final credentials = ref.watch(CredentialsInit.storage.oa.$credentials);
    return [
      buildTip(context).padSymmetric(v: 30),
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
      buildImportButton(context).padAll(24),
    ].column(key: key, maa: MainAxisAlignment.center, caa: CrossAxisAlignment.center);
  }

  Future<Timetable?> handleTimetableData(
    Timetable timetable,
    SemesterInfo info, {
    bool fillFundamentalInfo = true,
  }) async {
    final SemesterInfo(:exactYear, :semester) = info;
    // fetch start date of current semester from ug reg
    final userType = ref.read(CredentialsInit.storage.oa.$userType);
    final resolvedStartDate = await fetchStartDateOfCurrentSemester(info, userType);
    timetable = timetable.copyWith(
      semester: semester,
      startDate: resolvedStartDate,
      schoolYear: exactYear,
    );
    if (fillFundamentalInfo) {
      timetable = timetable.copyWith(
        name: timetable.name.isNotEmpty
            ? null
            : i18n.import.defaultName(semester.l10n(), exactYear.toString(), (exactYear + 1).toString()),
        startDate: await fetchStartDateOfCurrentSemester(info, userType) ?? estimateStartDate(exactYear, semester),
        signature: Meta.userRealName ?? Settings.lastSignature,
      );
    }
    if (!mounted) return null;
    final newTimetable = await processImportedTimetable(context, timetable);
    if (newTimetable != null) {
      return newTimetable;
    }
    return null;
  }

  Widget buildImportButton(BuildContext ctx) {
    return FilledButton(
      onPressed: _status == ImportStatus.importing ? null : _onImport,
      child: i18n.import.tryImportBtn.text(),
    );
  }

  Future<Timetable> fetchTimetable(SemesterInfo info) async {
    final userType = ref.read(CredentialsInit.storage.oa.$userType);
    return switch (userType) {
      OaUserType.undergraduate => TimetableInit.service.fetchUgTimetable(info),
      OaUserType.postgraduate => TimetableInit.service.fetchPgTimetable(info),
      OaUserType.worker => throw Exception("Timetable importing not supported"),
      _ => throw Exception("Timetable importing not supported"),
    };
  }

  void _onImport() async {
    if (ref.read(CredentialsInit.storage.oa.$userType) == OaUserType.freshman) {
      await onFreshmanImport(context);
      return;
    }
    setState(() {
      _status = ImportStatus.importing;
    });
    try {
      final selected = this.selected;
      final timetable = await fetchTimetable(selected);
      if (!mounted) return;
      setState(() {
        _status = ImportStatus.end;
      });
      final newTimetable = await handleTimetableData(
        timetable,
        selected,
        fillFundamentalInfo: ref.read(CredentialsInit.storage.oa.$userType) != OaUserType.undergraduate,
      );
      if (!mounted) return;
      context.pop(newTimetable);
    } catch (error, stackTrace) {
      debugPrintError(error, stackTrace);
      setState(() {
        _status = ImportStatus.failed;
      });
      if (!mounted) return;
      await context.showTip(
        title: i18n.import.failed,
        desc: error is DioException ? i18n.import.networkFailedDesc : i18n.import.failedDesc,
        primary: i18n.ok,
      );
    } finally {
      if (_status == ImportStatus.importing) {
        setState(() {
          _status = ImportStatus.end;
        });
      }
    }
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
