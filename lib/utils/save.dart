import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/adaptive/dialog.dart';

class PromptSaveBeforeQuitScope extends StatelessWidget {
  final bool changed;
  final FutureOr<void> Function() onSave;
  final Widget child;

  const PromptSaveBeforeQuitScope({
    super.key,
    required this.changed,
    required this.onSave,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !changed,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmSave = await context.showDialogRequest(
          desc: "你有未保存的更改，想要保存吗？",
          primary: "保存并退出",
          secondary: "丢弃",
          secondaryDestructive: true,
          dismissible: true,
        );
        if (confirmSave == true) {
          await onSave();
        } else if (confirmSave == false) {
          if (!context.mounted) return;
          context.pop();
        }
      },
      child: child,
    );
  }
}
