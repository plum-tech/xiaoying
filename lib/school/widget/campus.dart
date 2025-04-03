import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/settings/settings.dart';
import 'package:rettulf/rettulf.dart';

class CampusSelector extends ConsumerWidget {
  const CampusSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<Campus>(
      segments: Campus.values
          .map((e) => ButtonSegment<Campus>(
                icon: Icon(context.icons.location),
                value: e,
                label: e.l10n().text(),
              ))
          .toList(),
      selected: <Campus>{ref.watch(Settings.$campus) ?? Campus.fengxian},
      onSelectionChanged: (newSelection) async {
        ref.read(Settings.$campus.notifier).set(newSelection.first);
        await HapticFeedback.mediumImpact();
      },
    );
  }
}
