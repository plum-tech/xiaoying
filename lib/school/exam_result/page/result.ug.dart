import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/design/animation/progress.dart';
import 'package:mimir/design/widget/common.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/school/widget/semester.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/utils/error.dart';

import '../entity/result.ug.dart';
import '../init.dart';
import '../widget/ug.dart';
import '../i18n.dart';
import '../x.dart';

class ExamResultUgPage extends ConsumerStatefulWidget {
  const ExamResultUgPage({super.key});

  @override
  ConsumerState<ExamResultUgPage> createState() => _ExamResultUgPageState();
}

class _ExamResultUgPageState extends ConsumerState<ExamResultUgPage> {
  static SemesterInfo? _lastSemesterInfo;
  late SemesterInfo initial = _lastSemesterInfo ?? estimateSemesterInfo();
  late List<ExamResultUg>? resultList = ExamResultInit.ugStorage.getResultList(initial);
  bool fetching = false;
  final $loadingProgress = ValueNotifier(0.0);
  late SemesterInfo selected = initial;
  final scrollAreaKey = GlobalKey();
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  void dispose() {
    $loadingProgress.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> fetch() async {
    if (!mounted) return;
    setState(() {
      fetching = true;
    });
    try {
      final (:semester2Results, all: _) = await XExamResult.fetchAndCacheExamResultUgEachSemester(
        onProgress: (p) {
          if (!mounted) return;
          $loadingProgress.value = p;
        },
      );
      if (!mounted) return;
      setState(() {
        resultList = semester2Results[selected];
        fetching = false;
      });
      $loadingProgress.value = 0;
    } catch (error, stackTrace) {
      handleRequestError(error, stackTrace);
      if (!mounted) return;
      setState(() {
        fetching = false;
      });
      $loadingProgress.value = 0;
    }
  }

  Future<void> onChangeSemester(SemesterInfo info) async {
    if (!mounted) return;
    setState(() {
      resultList = ExamResultInit.ugStorage.getResultList(info);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultList = this.resultList?.sorted(ExamResultUg.compareByTime).reversed.toList();
    return Scaffold(
      body: CustomScrollView(
        key: scrollAreaKey,
        controller: controller,
        slivers: [
          SliverAppBar.medium(
            title: i18n.title.text(),
            actions: [
              PlatformTextButton(
                child: i18n.gpa.title.text(),
                onPressed: () async {
                  await context.push("/exam/result/ug/gpa");
                },
              )
            ],
          ),
          SliverToBoxAdapter(
            child: buildSemesterSelector(),
          ),
          if (resultList != null)
            if (resultList.isEmpty)
              SliverFillRemaining(
                child: LeavingBlank(
                  icon: Icons.inbox_outlined,
                  desc: i18n.noResultsTip,
                ),
              )
            else
              SliverList.builder(
                itemCount: resultList.length,
                itemBuilder: (item, i) => ExamResultUgTile(
                  resultList[i],
                ).inFilledCard(clip: Clip.hardEdge),
              ),
        ],
      ),
      floatingActionButton: fetching ? $loadingProgress >> (ctx, value) => AnimatedProgressCircle(value: value) : null,
    );
  }

  Widget buildSemesterSelector() {
    final credentials = ref.watch(CredentialsInit.storage.oa.$credentials);
    return SemesterSelector(
      initial: initial,
      baseYear: getAdmissionYearFromStudentId(credentials?.account),
      onSelected: (newSelection) {
        _lastSemesterInfo = newSelection;
        setState(() {
          selected = newSelection;
          resultList = ExamResultInit.ugStorage.getResultList(newSelection);
        });
      },
    );
  }
}
