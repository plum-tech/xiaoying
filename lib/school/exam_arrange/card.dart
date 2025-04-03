import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/widget/app.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/school/exam_arrange/entity/exam.dart';
import 'package:mimir/school/exam_arrange/init.dart';
import 'package:rettulf/rettulf.dart';
import 'package:super_context_menu/super_context_menu.dart';

import "i18n.dart";
import 'widget/exam.dart';

class ExamArrangeAppCard extends ConsumerStatefulWidget {
  const ExamArrangeAppCard({super.key});

  @override
  ConsumerState<ExamArrangeAppCard> createState() => _ExamArrangeAppCardState();
}

class _ExamArrangeAppCardState extends ConsumerState<ExamArrangeAppCard> {
  @override
  Widget build(BuildContext context) {
    final storage = ExamArrangeInit.storage;
    final currentSemester = estimateSemesterInfo();
    final examList = ref.watch(storage.$examListFamily(currentSemester));
    return AppCard(
      title: i18n.title.text(),
      view: examList != null ? buildMostRecentExam(examList) : null,
      leftActions: [
        FilledButton.icon(
          onPressed: () {
            context.push("/exam/arrangement");
          },
          icon: const Icon(Icons.calendar_month),
          label: i18n.check.text(),
        ),
      ],
    );
  }

  Widget? buildMostRecentExam(List<ExamEntry> examList) {
    if (examList.isEmpty) return null;
    final now = DateTime.now();
    examList = examList
        .where((exam) => !exam.disqualified)
        .where((exam) => exam.time?.start.isAfter(now) ?? false)
        .sorted(ExamEntry.compareByTime)
        .toList();
    // most recent exam
    final mostRecent = examList.firstOrNull;
    if (mostRecent == null) return null;
    return buildExam(mostRecent);
  }

  Widget buildExam(ExamEntry exam) {
    if (!supportContextMenu) {
      return ExamCard(exam);
    }
    return Builder(builder: (context) {
      return ContextMenuWidget(
        menuProvider: (MenuRequest request) {
          return Menu(
            children: [
              MenuAction(
                image: MenuImage.icon(context.icons.share),
                title: i18n.share,
                callback: () async {
                  await shareExamArrange(exam: exam, context: context);
                },
              ),
            ],
          );
        },
        child: ExamCard(exam),
      );
    });
  }
}

Future<void> shareExamArrange({
  required ExamEntry exam,
  required BuildContext context,
}) async {
  var text = "${exam.courseName}, ${exam.buildDate(context)}, ${exam.buildTime(context)}, ${exam.place}";
  if (exam.seatNumber != null) {
    text += ", ${i18n.seatNumber} ${exam.seatNumber}";
  }
  await Share.share(
    text,
    sharePositionOrigin: context.getSharePositionOrigin(),
  );
}

class ExamCard extends StatelessWidget {
  final ExamEntry exam;

  const ExamCard(
    this.exam, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ExamCardContent(exam).inCard();
  }
}
