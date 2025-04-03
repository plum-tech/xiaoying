import 'package:flutter/material.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/adaptive/swipe.dart';
import 'package:mimir/design/widget/common.dart';
import 'package:mimir/school/electricity/entity/room.dart';
import 'package:mimir/widget/search.dart';
import 'package:rettulf/rettulf.dart';
import '../i18n.dart';

const _emptyIndicator = Object();

Future<String?> searchRoom({
  String? initial,
  required BuildContext ctx,
  required ValueNotifier<List<String>> $searchHistory,
  required List<String> roomList,
}) async {
  final result = await showSearch(
    useRootNavigator: true,
    context: ctx,
    query: initial,
    delegate: ItemSearchDelegate.highlight(
      keyboardType: TextInputType.number,
      searchHistory: $searchHistory,
      emptyHistoryBuilder: (ctx) => LeavingBlank(
        icon: Icons.history,
        desc: i18n.emptyHistoryTip,
      ),
      emptyCandidateBuilder: (ctx) => LeavingBlank(
        icon: Icons.search_off,
        desc: i18n.noMatchedRoomNumbers,
      ),
      candidateBuilder: (ctx, items, highlight, selectIt) {
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            final (full, highlighted) = highlight(item);
            final room = DormitoryRoom.fromFullString(full);
            return ListTile(
              title: HighlightedText(
                full: full,
                highlighted: highlighted,
                baseStyle: ctx.textTheme.bodyLarge,
              ),
              subtitle: room.l10n().text(),
              onTap: () {
                selectIt(item);
              },
            );
          },
        );
      },
      historyBuilder: (ctx, items, stringify, selectIt) {
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            final full = stringify(item);
            final room = DormitoryRoom.fromFullString(full);
            return WithSwipeAction(
              right: SwipeAction.delete(
                icon: ctx.icons.delete,
                action: () {
                  final newList = List.of($searchHistory.value);
                  newList.removeAt(i);
                  $searchHistory.value = newList;
                },
              ),
              childKey: ValueKey(item),
              child: ListTile(
                leading: const Icon(Icons.history),
                title: HighlightedText(
                  full: full,
                  baseStyle: ctx.textTheme.bodyLarge,
                ),
                subtitle: room.l10n().text(),
                onTap: () {
                  selectIt(item);
                },
              ),
            );
          },
        );
      },
      candidates: roomList,
      queryProcessor: _keepOnlyNumber,
      invalidSearchTip: i18n.searchInvalidTip,
      childAspectRatio: 2,
      maxCrossAxisExtent: 150.0,
      emptyIndicator: _emptyIndicator,
    ),
  );
  return result is String ? result : null;
}

String _keepOnlyNumber(String raw) {
  return String.fromCharCodes(raw.codeUnits.where((e) => e >= 48 && e < 58));
}
