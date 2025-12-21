import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/animation/progress.dart';
import 'package:rettulf/rettulf.dart';
import '../entity/display.dart';
import '../i18n.dart';
import '../entity/timetable_entity.dart';
import '../init.dart';
import '../entity/pos.dart';
import '../widget/timetable/board.dart';

class TimetableBoardPage extends ConsumerStatefulWidget {
  final TimetableEntity timetable;

  const TimetableBoardPage({
    super.key,
    required this.timetable,
  });

  @override
  ConsumerState<TimetableBoardPage> createState() => _TimetableBoardPageState();
}

class _TimetableBoardPageState extends ConsumerState<TimetableBoardPage> {
  final $displayMode = ValueNotifier(TimetableInit.storage.lastDisplayMode ?? DisplayMode.weekly);
  late final ValueNotifier<TimetablePos> $currentPos;
  var syncing = false;

  TimetableEntity get timetable => widget.timetable;

  @override
  void initState() {
    super.initState();
    $displayMode.addListener(() {
      TimetableInit.storage.lastDisplayMode = $displayMode.value;
    });
    $currentPos = ValueNotifier(timetable.type.locate(DateTime.now()));
  }

  @override
  void dispose() {
    $displayMode.dispose();
    $currentPos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: $currentPos >> (ctx, pos) => i18n.weekOrderedName(number: pos.weekIndex + 1).text(),
        actions: [
          buildSwitchViewButton(),
          PlatformTextButton(
            child: "你的课程表".text(),
            onPressed: () async {
              await context.push("/timetable/mine");
            },
          )
        ],
      ),
      body: BlockWhenLoading(
        blocked: syncing,
        child: TimetableBoard(
          timetable: timetable,
          $displayMode: $displayMode,
          $currentPos: $currentPos,
        ),
      ),
    );
  }

  Widget buildSwitchViewButton() {
    return $displayMode >>
        (ctx, mode) => SegmentedButton<DisplayMode>(
              showSelectedIcon: false,
              style: ButtonStyle(
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 4)),
                visualDensity: VisualDensity.compact,
              ),
              segments: DisplayMode.values
                  .map((e) => ButtonSegment<DisplayMode>(
                        value: e,
                        label: e.l10n().text(),
                      ))
                  .toList(),
              selected: <DisplayMode>{mode},
              onSelectionChanged: (newSelection) {
                $displayMode.value = mode.toggle();
              },
            );
  }
}
