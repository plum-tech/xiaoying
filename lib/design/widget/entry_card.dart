import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart' hide isCupertino;
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:mimir/design/adaptive/menu.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/widget/card.dart';
import 'package:super_context_menu/super_context_menu.dart';

enum EntryActionType {
  edit,
  share,
  other;
}

class EntryAction {
  final IconData? icon;
  final bool main;
  final String label;
  final EntryActionType type;
  final bool oneShot;
  final SingleActivator? activator;
  final Future<void> Function() action;

  const EntryAction({
    required this.label,
    this.main = false,
    this.icon,
    this.oneShot = false,
    required this.action,
    this.activator,
    this.type = EntryActionType.other,
  });

  const EntryAction.edit({
    required this.label,
    this.main = false,
    this.oneShot = false,
    this.icon,
    required this.action,
    this.activator,
  }) : type = EntryActionType.edit;

  const EntryAction.delete({
    required this.label,
    this.main = false,
    this.icon,
    required this.action,
    this.activator = const SingleActivator(LogicalKeyboardKey.delete),
  })  : oneShot = true,
        type = EntryActionType.edit;
}

class EntrySelectAction {
  final String selectLabel;
  final String selectedLabel;
  final Future<void> Function() action;

  const EntrySelectAction({
    required this.selectLabel,
    required this.selectedLabel,
    required this.action,
  });

  EntryAction toAction(BuildContext context) {
    return EntryAction(
      label: selectLabel,
      oneShot: true,
      icon: context.icons.checkMark,
      action: action,
    );
  }
}

class EntryCard extends StatelessWidget {
  final bool selected;
  final String title;
  final Widget Function(BuildContext context) itemBuilder;
  final Widget Function(BuildContext context, List<Widget> Function(BuildContext context)? actionsBuilder)
      detailsBuilder;
  final List<EntryAction> Function(BuildContext context) actions;
  final EntrySelectAction? Function(BuildContext context) selectAction;
  final EntryAction Function(BuildContext context)? deleteAction;

  const EntryCard({
    super.key,
    required this.title,
    required this.selected,
    required this.itemBuilder,
    required this.actions,
    required this.selectAction,
    required this.detailsBuilder,
    this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    return supportContextMenu ? buildCardWithContextMenu(context) : buildCardWithDropMenu(context);
  }

  Widget buildCardWithDropMenu(BuildContext context) {
    final actions = this.actions(context);
    final mainActions = actions.where((action) => action.main).toList();
    final secondaryActions = actions.where((action) => !action.main).toList();
    final selectAction = this.selectAction(context);

    Widget buildMaterialMainActions() {
      final all = <Widget>[];
      if (selectAction != null) {
        all.add(
          selected
              ? FilledButton.icon(
                  icon: Icon(context.icons.checkMark),
                  onPressed: null,
                  label: selectAction.selectedLabel.text(),
                )
              : FilledButton(
                  onPressed: selectAction.action,
                  child: selectAction.selectLabel.text(),
                ),
        );
      }
      for (final action in mainActions) {
        all.add(FilledButton.tonal(
          onPressed: action.action,
          child: action.label.text(),
        ));
      }
      return all.wrap(spacing: 4);
    }

    Widget buildSecondaryActionPopup() {
      return PullDownMenuButton(
        itemBuilder: (ctx) {
          final all = <PullDownEntry>[];
          for (final action in secondaryActions) {
            final callback = action.action;
            all.add(PullDownItem(
              title: action.label,
              icon: action.icon,
              onTap: () async {
                await callback();
              },
            ));
          }
          final deleteAction = this.deleteAction;
          if (deleteAction != null) {
            final deleteActionWidget = deleteAction(context);
            all.add(const PullDownDivider());
            all.add(PullDownItem(
              title: deleteActionWidget.label,
              icon: deleteActionWidget.icon,
              onTap: () async {
                await deleteActionWidget.action();
              },
            ));
          }
          return all;
        },
      );
    }

    return AnimatedScale(
      scale: selected ? 0.98 : 1,
      duration: Durations.medium1,
      child: InkWell(
        child: [
          itemBuilder(context),
          OverflowBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              buildMaterialMainActions(),
              buildSecondaryActionPopup(),
            ],
          ),
        ].column(caa: CrossAxisAlignment.start).padSymmetric(v: 10, h: 15),
        onTap: () async {
          await context.showSheet((ctx) => detailsBuilder(context, buildDetailsActions));
        },
      ).inAnyCard(
        type: selected ? CardVariant.filled : CardVariant.outlined,
        clip: Clip.hardEdge,
      ),
    );
  }

  Widget buildCardWithContextMenu(BuildContext context) {
    return Builder(
      builder: (context) {
        final actions = this.actions(context);
        final deleteAction = this.deleteAction?.call(context);
        return ContextMenuWidget(
          menuProvider: (MenuRequest request) {
            return Menu(
              children: buildMenuActions(
                context,
                actions: actions,
                selectAction: selectAction(context),
                deleteAction: deleteAction,
              ),
            );
          },
          child: buildCardWithContextMenuBody(
            context,
            selectAction: selectAction(context),
          ),
        );
      },
    );
  }

  Widget buildCardWithContextMenuBody(
    BuildContext context, {
    required EntrySelectAction? selectAction,
  }) {
    Widget widget = [
      itemBuilder(context),
      OverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          if (selectAction != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: selected ? null : selectAction.action,
              child: selected
                  ? Icon(context.icons.checkMark, color: context.colorScheme.primary)
                  : Icon(context.icons.checkBoxBlankOutlineRounded),
            ),
        ],
      ),
    ].column(caa: CrossAxisAlignment.start).padOnly(t: 12, l: 12, r: 8, b: 4);
    if (isCupertino) {
      return GestureDetector(
        onTap: () => showDetailsSheet(context),
        child: selectedCard(
          child: widget,
        ),
      );
    } else {
      return selectedCard(
        child: InkWell(
          onTap: () => showDetailsSheet(context),
          child: widget,
        ),
      );
    }
  }

  Widget selectedCard({required Widget child}) {
    return child.inAnyCard(
      type: selected ? CardVariant.filled : CardVariant.outlined,
      clip: Clip.hardEdge,
    );
  }

  Future<void> showDetailsSheet(BuildContext context) async {
    await context.showSheet((ctx) => detailsBuilder(ctx, buildDetailsActions));
  }

  List<MenuAction> buildMenuActions(
    BuildContext context, {
    required List<EntryAction> actions,
    required EntrySelectAction? selectAction,
    required EntryAction? deleteAction,
  }) {
    final all = <MenuAction>[];
    if (selectAction != null && !selected) {
      final selectCallback = selectAction.action;
      all.add(MenuAction(
        image: MenuImage.icon(context.icons.checkMark),
        title: selectAction.selectLabel,
        callback: selectCallback,
      ));
    }
    for (final action in actions) {
      final callback = action.action;
      final icon = action.icon;
      all.add(MenuAction(
        image: icon == null ? null : MenuImage.icon(icon),
        title: action.label,
        activator: action.activator,
        callback: callback,
      ));
    }
    if (deleteAction != null) {
      final icon = deleteAction.icon;
      all.add(MenuAction(
        image: icon == null ? null : MenuImage.icon(icon),
        title: deleteAction.label,
        attributes: const MenuActionAttributes(destructive: true),
        activator: deleteAction.activator,
        callback: deleteAction.action,
      ));
    }
    assert(all.isNotEmpty, "CupertinoContextMenuActions can't be empty");
    return all;
  }

  ({EntryAction main, List<EntryAction> secondary}) separateActions4Details(
    BuildContext context,
    List<EntryAction> actions, {
    EntrySelectAction? select,
  }) {
    final main = actions.where((action) => action.main).firstOrNull;
    if (main != null) {
      return (
        main: main,
        secondary: [
          if (select != null) select.toAction(context),
          ...actions.where((action) => !action.main),
        ]
      );
    }
    if (select != null && !selected) {
      return (main: select.toAction(context), secondary: actions);
    }
    final edit = actions.where((action) => action.type == EntryActionType.edit).firstOrNull;
    if (edit != null) {
      return (
        main: edit,
        secondary: [
          if (select != null) select.toAction(context),
          ...actions.where((action) => action.type != EntryActionType.edit),
        ]
      );
    }
    return (main: actions.first, secondary: actions.sublist(min(1, actions.length)));
  }

  List<Widget> buildDetailsActions(BuildContext context) {
    final all = <Widget>[];
    final actions = this.actions(context);
    final deleteAction = this.deleteAction?.call(context);
    final (:main, :secondary) = separateActions4Details(context, actions, select: selectAction.call(context));
    all.add(PlatformTextButton(
      onPressed: () async {
        if (main.oneShot) {
          if (!context.mounted) return;
          context.navigator.pop();
        }
        await main.action();
      },
      child: main.label.text(),
    ));
    all.add(PullDownMenuButton(
      itemBuilder: (ctx) {
        return [
          ...secondary.map(
            (action) => PullDownItem(
              icon: action.icon,
              title: action.label,
              onTap: () async {
                if (action.oneShot) {
                  if (!context.mounted) return;
                  context.navigator.pop();
                }
                await action.action();
              },
            ),
          ),
          if (deleteAction != null) ...[
            const PullDownDivider(),
            PullDownItem.delete(
              title: deleteAction.label,
              icon: context.icons.delete,
              onTap: () async {
                await deleteAction.action();
                if (!context.mounted) return;
                context.navigator.pop();
              },
            ),
          ],
        ];
      },
    ));
    return all;
  }
}
