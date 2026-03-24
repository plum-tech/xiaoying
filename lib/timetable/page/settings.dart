import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/settings/settings.dart';
import 'package:rettulf/rettulf.dart';

class TimetableSettingsPage extends StatefulWidget {
  const TimetableSettingsPage({super.key});

  @override
  State<TimetableSettingsPage> createState() => _TimetableSettingsPageState();
}

class _TimetableSettingsPageState extends State<TimetableSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            pinned: true,
            snap: false,
            floating: false,
            title: "课程表".text(),
          ),
          SliverList.list(
            children: const [AutoUseImportedTile(), QuickLookCourseOnTapTile()],
          ),
        ],
      ),
    );
  }
}

class QuickLookCourseOnTapTile extends ConsumerWidget {
  const QuickLookCourseOnTapTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(Settings.timetable.$quickLookLessonOnTap);
    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.touch_app),
      title: "点击快速查看一节课".text(),
      subtitle: "在周课程表中长按查看完整课程".text(),
      value: on,
      onChanged: (newV) {
        ref.read(Settings.timetable.$quickLookLessonOnTap.notifier).set(newV);
      },
    );
  }
}

class AutoUseImportedTile extends ConsumerWidget {
  const AutoUseImportedTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(Settings.timetable.$autoUseImported);
    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.calendar_month),
      title: "自动使用新课程表".text(),
      subtitle: "自动使用新导入的课程表".text(),
      value: on,
      onChanged: (newV) {
        ref.read(Settings.timetable.$autoUseImported.notifier).set(newV);
      },
    );
  }
}
