import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart' hide isCupertino;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/design/adaptive/editor.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/widget/app.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/design/widget/task_builder.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/utils/async_event.dart';
import 'package:rettulf/rettulf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:super_context_menu/super_context_menu.dart';

import '../event.dart';
import 'x.dart';
import 'entity/balance.dart';
import 'i18n.dart';
import 'init.dart';
import 'widget/card.dart';

class ElectricityBalanceAppCard extends ConsumerStatefulWidget {
  const ElectricityBalanceAppCard({super.key});

  @override
  ConsumerState<ElectricityBalanceAppCard> createState() => _ElectricityBalanceAppCardState();
}

class _ElectricityBalanceAppCardState extends ConsumerState<ElectricityBalanceAppCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late final EventSubscription $refreshEvent;

  @override
  initState() {
    super.initState();
    $refreshEvent = schoolEventBus.addListener(() async {
      await refresh(active: true);
    });
    if (Settings.school.electricity.autoRefresh) {
      refresh(active: false);
    }
  }

  @override
  dispose() {
    $refreshEvent.cancel();
    super.dispose();
  }

  /// The electricity balance is refreshed approximately every 15 minutes.
  Future<void> refresh({required bool active}) async {
    final selectedRoom = Settings.school.electricity.selectedRoom;
    if (selectedRoom == null) return;
    try {
      await XElectricity.refresh(
        selectedRoom: selectedRoom,
      );
    } catch (error) {
      if (active) {
        if (!mounted) return;
        context.showSnackBar(content: i18n.refreshFailedTip.text());
      }
      return;
    }
    if (active) {
      if (!mounted) return;
      context.showSnackBar(content: i18n.refreshSuccessTip.text());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final storage = ElectricityBalanceInit.storage;
    final lastBalance = ref.watch(storage.$lastBalance);
    final selectedRoom = ref.watch(Settings.school.electricity.$selectedRoom);
    final lastUpdateTime = ref.watch(storage.$lastUpdateTime);
    final balance = lastBalance?.roomNumber == selectedRoom ? lastBalance : null;
    final roomNumber = balance != null
        ? "#${balance.roomNumber}"
        : selectedRoom != null
            ? "#$selectedRoom"
            : null;
    return AppCard(
      view: selectedRoom != null && balance != null
          ? buildBalanceCard(
              balance: balance,
              selectedRoom: selectedRoom,
            )
          : const SizedBox.shrink(),
      title: (roomNumber == null ? i18n.title : "${i18n.title} $roomNumber").text(),
      subtitle: lastUpdateTime != null ? i18n.lastUpdateTime(context.formatMdhmNum(lastUpdateTime)).text() : null,
      leftActions: [
        FilledButton.icon(
          onPressed: () async {
             final room =await Editor.showStringEditor(context, initial: selectedRoom ?? "");
            if (room == null) return;
            XElectricity.setSelectedRoom(room);
            await refresh(active: true);
          },
          label: i18n.searchRoom.text(),
          icon: Icon(context.icons.search),
        ),
      ],
      rightActions: [
        if (balance != null && selectedRoom != null && !supportContextMenu)
          TaskBuilder(
            task: () async {
              await shareBalance(balance: balance, selectedRoom: selectedRoom, context: context);
            },
            builder: (context, task, running) {
              return PlatformIconButton(
                material: (ctx, p) {
                  return MaterialIconButtonData(
                    tooltip: i18n.share,
                  );
                },
                onPressed: task,
                icon: Icon(context.icons.share),
              );
            },
          ),
      ],
    );
  }

  Widget buildBalanceCard({
    required ElectricityBalance balance,
    required String selectedRoom,
  }) {
    if (!supportContextMenu) {
      return Dismissible(
        direction: DismissDirection.endToStart,
        key: const ValueKey("Balance"),
        onDismissed: (dir) async {
          await HapticFeedback.heavyImpact();
          XElectricity.clearSelectedRoom();
        },
        child: buildCard(balance),
      );
    }
    return Builder(
      builder: (ctx) => ContextMenuWidget(
        menuProvider: (MenuRequest request) {
          return Menu(
            children: [
              MenuAction(
                image: MenuImage.icon(context.icons.share),
                title: i18n.share,
                callback: () async {
                  await shareBalance(balance: balance, selectedRoom: selectedRoom, context: ctx);
                },
              ),
              MenuAction(
                image: MenuImage.icon(context.icons.delete),
                title: i18n.delete,
                attributes: const MenuActionAttributes(destructive: true),
                activator: const SingleActivator(LogicalKeyboardKey.delete),
                callback: () async {
                  await HapticFeedback.heavyImpact();
                  Settings.school.electricity.selectedRoom = null;
                },
              ),
            ],
          );
        },
        child: buildCard(balance),
      ),
    );
  }

  Widget buildCard(ElectricityBalance balance) {
    return ElectricityBalanceCard(
      balance: balance,
    ).sized(h: 120);
  }
}

Future<void> shareBalance({
  required ElectricityBalance balance,
  required String selectedRoom,
  required BuildContext context,
}) async {
  final text =
      "#$selectedRoom: ${i18n.unit.rmb(balance.balance.toStringAsFixed(2))}, ${i18n.unit.powerKwh(balance.remainingPower.toStringAsFixed(2))}";
  await Share.share(
    text,
    sharePositionOrigin: context.getSharePositionOrigin(),
  );
}
