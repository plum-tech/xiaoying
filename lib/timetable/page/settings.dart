import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/settings/settings.dart';
import 'package:rettulf/rettulf.dart';
import '../i18n.dart';

class TimetableSettingsPage extends StatefulWidget {
  const TimetableSettingsPage({
    super.key,
  });

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
            title: i18n.navigation.text(),
          ),
          SliverList.list(
            children: [
              const AutoUseImportedTile(),
              const QuickLookCourseOnTapTile(),
              const Divider(),
              buildCellStyle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCellStyle() {
    return ListTile(
      leading: const Icon(Icons.view_comfortable_outlined),
      title: i18n.settings.cellStyle.text(),
      subtitle: i18n.settings.cellStyleDesc.text(),
      trailing: const Icon(Icons.open_in_new),
      onTap: () async {
        await context.push("/timetable/cell-style");
      },
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
      title: i18n.settings.quickLookLessonOnTap.text(),
      subtitle: i18n.settings.quickLookLessonOnTapDesc.text(),
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
      title: i18n.settings.autoUseImported.text(),
      subtitle: i18n.settings.autoUseImportedDesc.text(),
      value: on,
      onChanged: (newV) {
        ref.read(Settings.timetable.$autoUseImported.notifier).set(newV);
      },
    );
  }
}
