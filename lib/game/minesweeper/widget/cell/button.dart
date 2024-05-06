import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rettulf/build_context.dart';
import 'package:sit/game/utils.dart';
import '../../entity/cell.dart';
import '../../game.dart';

class CellButton extends ConsumerWidget {
  const CellButton({
    super.key,
    required this.cell,
    required this.coverVisible,
    required this.flagVisible,
    required this.refresh,
  });

  final Cell cell;
  final bool coverVisible;
  final bool flagVisible;
  final void Function() refresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.read(minesweeperState.notifier);
    return !(cell.state == CellState.blank && cell.minesAround == 0)
        ? Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
                color: context.colorScheme.surface,
              ),
            ),
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: !coverVisible ? Colors.transparent : context.colorScheme.surfaceVariant,
              onTap: !coverVisible
                  ? null
                  : () {
                      // Click a Cover Cell => Blank
                      if (!flagVisible) {
                        manager.dig(cell: cell);
                        applyGameHapticFeedback();
                      } else {
                        // Click a Flag Cell => Cancel Flag (Covered)
                        manager.removeFlag(cell: cell);
                      }
                      refresh();
                    },
              onDoubleTap: coverVisible
                  ? null
                  : () {
                      bool anyChanged = false;
                      anyChanged |= manager.digAroundBesidesFlagged(cell: cell);
                      anyChanged |= manager.flagRestCovered(cell: cell);
                      if (anyChanged) {
                        applyGameHapticFeedback();
                      }
                      refresh();
                    },
              onLongPress: !coverVisible
                  ? null
                  : () {
                      manager.toggleFlag(cell: cell);
                      applyGameHapticFeedback();
                      refresh();
                    },
              onSecondaryTap: !coverVisible
                  ? null
                  : () {
                      manager.toggleFlag(cell: cell);
                      applyGameHapticFeedback();
                      refresh();
                    },
            ),
          )
        : const SizedBox.shrink();
  }
}
