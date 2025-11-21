import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart' as w;
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:rettulf/rettulf.dart';

class SwipeAction {
  final VoidCallback action;
  final IconData? icon;
  final String? label;
  final bool fullSwipeAction;
  final bool destructive;
  final Color? color;

  const SwipeAction({
    required this.action,
    this.icon,
    this.label,
    this.fullSwipeAction = false,
    this.destructive = false,
    this.color = Colors.green,
  });

  const SwipeAction.delete({
    required this.action,
    this.icon,
    this.label,
  })  : destructive = true,
        fullSwipeAction = true,
        color = null;

  w.SwipeAction build(BuildContext context) {
    return w.SwipeAction(
      title: label,
      icon: Icon(icon, color: Colors.white),
      color: color ?? context.$red$,
      style: context.textTheme.titleSmall ?? const TextStyle(),
      performsFirstActionWithFullSwipe: fullSwipeAction,
      onTap: (w.CompletionHandler handler) async {
        await handler(destructive);
        action();
      },
    );
  }
}

class WithSwipeAction extends StatelessWidget {
  final Widget child;
  final SwipeAction? left;
  final SwipeAction? right;
  final Key childKey;

  const WithSwipeAction({
    super.key,
    required this.childKey,
    required this.child,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    final left = this.left;
    final right = this.right;
    return w.SwipeActionCell(
      key: childKey,
      backgroundColor: Colors.transparent,
      leadingActions: left == null
          ? null
          : <w.SwipeAction>[
              left.build(context),
            ],
      trailingActions: right == null
          ? null
          : <w.SwipeAction>[
              right.build(context),
            ],
      child: child,
    );
  }
}
