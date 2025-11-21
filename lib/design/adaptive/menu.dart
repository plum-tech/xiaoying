import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:rettulf/rettulf.dart';

import 'multiplatform.dart';

abstract class PullDownEntry {
  PullDownMenuEntry buildCupertino(BuildContext context);

  Widget buildMaterial(BuildContext context);
}

class PullDownDivider implements PullDownEntry {
  const PullDownDivider();

  @override
  PullDownMenuEntry buildCupertino(BuildContext context) {
    return const PullDownMenuDivider.large();
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return const Divider();
  }
}

class PullDownItem implements PullDownEntry {
  final String title;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool destructive;

  const PullDownItem({
    required this.title,
    this.onTap,
    this.icon,
    this.destructive = false,
  });

  const PullDownItem.edit({
    required this.title,
    this.onTap,
    this.icon,
    this.destructive = false,
  });

  const PullDownItem.delete({
    required this.title,
    this.onTap,
    this.icon,
  }) : destructive = true;

  @override
  PullDownMenuEntry buildCupertino(BuildContext context) {
    return PullDownMenuItem(
      onTap: onTap,
      title: title,
      isDestructive: destructive,
      icon: icon,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    final icon = this.icon;
    return MenuItemButton(
      leadingIcon: icon == null ? null : Icon(icon),
      onPressed: onTap,
      child: title.text(style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.onSurface)).padH(8),
    );
  }
}

class SelectableMenuItemButton extends StatelessWidget {
  final bool selected;
  final Widget? leading;
  final Widget child;
  final VoidCallback? onTap;

  const SelectableMenuItemButton({
    super.key,
    this.leading,
    required this.child,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      leadingIcon: leading,
      onPressed: () {
        onTap?.call();
      },
      trailingIcon: Icon(selected ? context.icons.checkMark : null),
      child: child,
    );
  }
}

class PullDownSelectable implements PullDownEntry {
  final bool selected;
  final String title;
  final VoidCallback? onTap;
  final IconData? icon;
  final IconData? cupertinoIcon;

  const PullDownSelectable({
    required this.title,
    required this.selected,
    this.onTap,
    this.icon,
    this.cupertinoIcon,
  });

  @override
  PullDownMenuEntry buildCupertino(BuildContext context) {
    return PullDownMenuItem.selectable(
      onTap: onTap,
      selected: selected,
      title: title,
      icon: cupertinoIcon ?? icon,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return SelectableMenuItemButton(
      leading: icon == null ? null : Icon(icon),
      selected: selected,
      onTap: onTap,
      child: title.text(style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.onSurface)),
    );
  }
}

class PullDownMenuButton extends StatefulWidget {
  final List<PullDownEntry> Function(BuildContext context) itemBuilder;
  final Widget Function(BuildContext context, IconData icon) iconBuilder;

  const PullDownMenuButton({
    super.key,
    required this.itemBuilder,
    this.iconBuilder = _buildIcon,
  });

  @override
  State<PullDownMenuButton> createState() => _PullDownMenuButtonState();
}

Widget _buildIcon(BuildContext context, IconData icon) {
  return Icon(icon);
}

class _PullDownMenuButtonState extends State<PullDownMenuButton> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isCupertino) {
      return PullDownButton(
        itemBuilder: (context) => widget.itemBuilder(context).map((item) => item.buildCupertino(context)).toList(),
        buttonBuilder: (context, showMenu) => CupertinoButton(
          onPressed: showMenu,
          padding: EdgeInsets.zero,
          child: widget.iconBuilder(context, CupertinoIcons.ellipsis_circle),
        ),
      );
    } else {
      return MenuAnchor(
        childFocusNode: _focus,
        clipBehavior: Clip.hardEdge,
        menuChildren: widget.itemBuilder(context).map((item) => item.buildMaterial(context)).toList(),
        consumeOutsideTap: true,
        builder: (ctx, controller, child) {
          return IconButton(
            focusNode: _focus,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: widget.iconBuilder(context, Icons.adaptive.more),
          );
        },
      );
    }
  }
}
