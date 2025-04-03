import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/design/widget/common.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/school/widget/semester.dart';
import 'package:mimir/utils/error.dart';

import '../entity/exam.dart';
import '../i18n.dart';
import '../init.dart';
import '../widget/exam.dart';

class ExamArrangementListPage extends ConsumerStatefulWidget {
  const ExamArrangementListPage({super.key});

  @override
  ConsumerState<ExamArrangementListPage> createState() => _ExamArrangementListPageState();
}

class _ExamArrangementListPageState extends ConsumerState<ExamArrangementListPage> {
  static SemesterInfo? _lastSemesterInfo;
  List<ExamEntry>? examList;
  bool fetching = false;
  late SemesterInfo initial = _lastSemesterInfo ?? estimateSemesterInfo();
  late SemesterInfo selected = initial;

  @override
  void initState() {
    super.initState();
    refresh(initial);
  }

  Future<void> refresh(SemesterInfo info) async {
    if (!mounted) return;
    setState(() {
      examList = ExamArrangeInit.storage.getExamList(info);
      fetching = true;
    });
    try {
      final examList = await ExamArrangeInit.service.fetchExamList(info);
      ExamArrangeInit.storage.setExamList(info, examList);
      if (info == selected) {
        if (!mounted) return;
        setState(() {
          this.examList = examList;
          fetching = false;
        });
      }
    } catch (error, stackTrace) {
      handleRequestError(error, stackTrace);
      if (!mounted) return;
      setState(() {
        fetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final examList = this.examList?.sorted(ExamEntry.compareByTime).reversed.toList();
    final now = DateTime.now();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: i18n.title.text(),
          ),
          SliverToBoxAdapter(
            child: buildSemesterSelector(),
          ),
          if (examList != null)
            if (examList.isEmpty)
              SliverFillRemaining(
                child: LeavingBlank(
                  icon: Icons.inbox_outlined,
                  desc: i18n.noExamsTip,
                ),
              )
            else
              SliverList.builder(
                itemCount: examList.length,
                itemBuilder: (ctx, i) {
                  final exam = examList[i];
                  return ExamCardContent(
                    exam,
                    enableAddEvent: exam.time?.end.isAfter(now) ?? false,
                  ).inFilledCard().padH(6);
                },
              ),
        ],
      ),
      floatingActionButton: !fetching ? null : const CircularProgressIndicator.adaptive(),
    );
  }

  Widget buildSemesterSelector() {
    final credentials = ref.watch(CredentialsInit.storage.oa.$credentials);
    return SemesterSelector(
      initial: initial,
      baseYear: getAdmissionYearFromStudentId(credentials?.account),
      onSelected: (newSelection) {
        setState(() {
          selected = newSelection;
        });
        _lastSemesterInfo = newSelection;
        refresh(newSelection);
      },
    );
  }
}
