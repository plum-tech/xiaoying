import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/widget/list_tile.dart';
import 'package:mimir/design/widget/navigation.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/exam_result/entity/result.ug.dart';
import '../i18n.dart';

class ExamResultUgDetailsPage extends StatefulWidget {
  final ExamResultUg result;

  const ExamResultUgDetailsPage(this.result, {super.key});

  @override
  State<ExamResultUgDetailsPage> createState() => _ExamResultDetailsPageState();
}

class _ExamResultDetailsPageState extends State<ExamResultUgDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final score = result.score;
    final time = result.time;
    final items = result.items.where((e) => e.score != null).toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: result.courseName.text(),
          ),
          SliverList.list(children: [
            if (score != null)
              DetailListTile(
                leading: const Icon(Icons.score),
                title: i18n.score,
                subtitle: result.score.toString(),
              )
            else
              PageNavigationTile(
                leading: const Icon(Icons.warning),
                title: i18n.courseNotEval.text(),
                subtitle: i18n.examRequireEvalTip.text(),
                path: '/teacher-eval',
              ),
            DetailListTile(
              leading: const Icon(Icons.class_),
              title: i18n.examType,
              subtitle: result.examType.l10n(),
            ),
            DetailListTile(
              leading: const Icon(Icons.view_timeline_outlined),
              title: i18n.course.semester,
              subtitle: result.semesterInfo.l10n(),
            ),
            if (time != null)
              DetailListTile(
                leading: const Icon(Icons.access_time),
                title: i18n.publishTime,
                subtitle: context.formatYmdhmNum(time),
              ),
            DetailListTile(
              leading: const Icon(Icons.numbers),
              title: i18n.course.courseCode,
              subtitle: result.courseCode.toString(),
            ),
            if (result.classCode.isNotEmpty)
              DetailListTile(
                leading: const Icon(Icons.group),
                title: i18n.course.classCode,
                subtitle: result.classCode.toString(),
              ),
            if (result.courseCat != CourseCat.none)
              DetailListTile(
                leading: const Icon(Icons.category),
                title: i18n.course.category,
                subtitle: result.courseCat.l10n(),
              ),
            if (result.teachers.isNotEmpty)
              DetailListTile(
                leading: Icon(result.teachers.length > 1 ? Icons.people : Icons.person),
                title: i18n.course.teacher(result.teachers.length), // plural
                subtitle: result.teachers.join(", "),
              ),
          ]),
          const SliverToBoxAdapter(
            child: Divider(),
          ),
          SliverGrid.extent(
            maxCrossAxisExtent: 240,
            childAspectRatio: 3,
            children: items
                .map((item) => ListTile(
                      title: "${item.scoreType} ${item.percentage}".text(),
                      subtitle: item.score.toString().text(),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
