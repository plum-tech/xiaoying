import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/l10n/common.dart';

const _i18n = _I18n();

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
          desc: _i18n.saveAndQuitRequest,
          primary: _i18n.saveAndQuit,
          secondary: _i18n.discard,
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

class PromptDiscardBeforeQuitScope extends StatelessWidget {
  final bool changed;
  final Widget child;

  const PromptDiscardBeforeQuitScope({
    super.key,
    required this.changed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !changed,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final cancel = await context.showDialogRequest(
          desc: _i18n.discardAndQuitRequest,
          primary: _i18n.discardAndQuit,
          secondary: _i18n.cancel,
          primaryDestructive: true,
          dismissible: true,
        );
        if (cancel == true) {
          if (!context.mounted) return;
          context.pop();
        }
      },
      child: child,
    );
  }
}

class _I18n with CommonI18nMixin {
  const _I18n();

  static const ns = "quitPrompt";

  String get saveAndQuitRequest => "$ns.request.saveAndQuit".tr();

  String get discardAndQuitRequest => "$ns.request.discardAndQuit".tr();

  String get saveAndQuit => "$ns.saveAndQuit".tr();

  String get discard => "$ns.discard".tr();

  String get discardAndQuit => "$ns.discardAndQuit".tr();
}
