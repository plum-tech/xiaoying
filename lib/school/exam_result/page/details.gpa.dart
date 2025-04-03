import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/widget/list_tile.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/exam_result/entity/gpa.dart';
import 'package:mimir/school/exam_result/widget/ug.dart';
import '../i18n.dart';

class ExamResultGpaItemDetailsPage extends StatefulWidget {
  final ExamResultGpaItem item;

  const ExamResultGpaItemDetailsPage(this.item, {super.key});

  @override
  State<ExamResultGpaItemDetailsPage> createState() => _ExamResultDetailsPageState();
}

class _ExamResultDetailsPageState extends State<ExamResultGpaItemDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final score = item.maxScore;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: item.courseName.text(),
          ),
          SliverList.list(children: [
            if (score != null)
              DetailListTile(
                leading: const Icon(Icons.score),
                title: i18n.maxScore,
                subtitle: score.toString(),
              ),
            DetailListTile(
              leading: const Icon(Icons.view_timeline_outlined),
              title: i18n.course.semester,
              subtitle: item.semesterInfo.l10n(),
            ),
            DetailListTile(
              leading: const Icon(Icons.numbers),
              title: i18n.course.courseCode,
              subtitle: item.courseCode.toString(),
            ),
            if (item.courseCat != CourseCat.none)
              DetailListTile(
                leading: const Icon(Icons.category),
                title: i18n.course.category,
                subtitle: item.courseCat.l10n(),
              ),
          ]),
          if (item.resit.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Divider(),
            ),
            SliverList.builder(
              itemCount: item.resit.length,
              itemBuilder: (ctx, i) {
                final result = item.resit[i];
                return ExamResultUgTile(result);
              },
            ),
          ],
          if (item.retake.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Divider(),
            ),
            SliverList.builder(
              itemCount: item.retake.length,
              itemBuilder: (ctx, i) {
                final result = item.retake[i];
                return ExamResultUgTile(result);
              },
            ),
          ],
        ],
      ),
    );
  }
}
