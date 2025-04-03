import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rettulf/rettulf.dart';
import 'package:universal_platform/universal_platform.dart';

import 'foundation.dart';

typedef PickerActionWidgetBuilder = Widget Function(BuildContext context, int? selectedIndex);
typedef DualPickerActionWidgetBuilder = Widget Function(BuildContext context, int? selectedIndexA, int? selectedIndexB);

extension DialogEx on BuildContext {
  /// return: whether the button was hit
  Future<bool> showTip({
    String? title,
    required String desc,
    required String primary,
    bool highlight = false,
    bool serious = false,
    bool dismissible = true,
  }) async {
    return showAnyTip(
      title: title,
      desc: (_) => desc.text(style: const TextStyle()),
      primary: primary,
      highlight: false,
      serious: serious,
      dismissible: dismissible,
    );
  }

  Future<bool> showAnyTip({
    String? title,
    required WidgetBuilder desc,
    required String primary,
    bool highlight = false,
    bool serious = false,
    bool dismissible = false,
  }) async {
    final dynamic confirm = await showAdaptiveDialog(
      barrierDismissible: dismissible,
      context: this,
      builder: (ctx) => $Dialog$(
          title: title,
          serious: serious,
          desc: desc,
          primary: $Action$(
            warning: highlight,
            text: primary,
            onPressed: () {
              ctx.navigator.pop(true);
            },
          )),
    );
    return confirm == true;
  }

  Future<bool?> showDialogRequest({
    String? title,
    required String desc,
    required String primary,
    required String secondary,
    bool dismissible = false,
    bool serious = false,
    bool primaryDestructive = false,
    bool secondaryDestructive = false,
  }) async {
    return await showAnyRequest(
      title: title,
      dismissible: dismissible,
      make: (_) => desc.text(style: const TextStyle()),
      primary: primary,
      secondary: secondary,
      serious: serious,
      primaryDestructive: primaryDestructive,
      secondaryDestructive: secondaryDestructive,
    );
  }

  Future<bool?> showActionRequest({
    String? title,
    required String desc,
    required String action,
    required String cancel,
    bool dismissible = true,
    bool destructive = false,
  }) async {
    if (UniversalPlatform.isIOS) {
      return showCupertinoActionRequest(
        title: title,
        desc: desc,
        action: action,
        dismissible: dismissible,
        cancel: cancel,
        destructive: destructive,
      );
    }
    return await showAnyRequest(
      title: title ?? action,
      make: (_) => desc.text(style: const TextStyle()),
      primary: action,
      secondary: cancel,
      dismissible: dismissible,
      primaryDestructive: destructive,
      serious: destructive,
    );
  }

  Future<bool?> showCupertinoActionRequest({
    String? title,
    required String desc,
    required String action,
    required String cancel,
    bool dismissible = true,
    bool destructive = false,
  }) async {
    return await showCupertinoModalPopup(
      context: this,
      barrierDismissible: dismissible,
      builder: (ctx) => CupertinoActionSheet(
        title: title?.text(),
        message: desc.text(),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: destructive,
            onPressed: () {
              ctx.pop(true);
            },
            child: action.text(),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            ctx.pop(false);
          },
          child: cancel.text(),
        ),
      ),
    );
  }

  Future<bool?> showAnyRequest({
    String? title,
    required WidgetBuilder make,
    required String primary,
    required String secondary,
    bool dismissible = false,
    bool serious = false,
    bool primaryDestructive = false,
    bool secondaryDestructive = false,
  }) async {
    return await showAdaptiveDialog(
      context: this,
      barrierDismissible: dismissible,
      builder: (ctx) => $Dialog$(
        title: title,
        serious: serious,
        desc: make,
        primary: $Action$(
          warning: primaryDestructive,
          text: primary,
          onPressed: () {
            ctx.navigator.pop(true);
          },
        ),
        secondary: $Action$(
          text: secondary,
          warning: secondaryDestructive,
          onPressed: () {
            ctx.navigator.pop(false);
          },
        ),
      ),
    );
  }

  Future<int?> showPicker({
    required int count,
    String? ok,
    double targetHeight = 240,
    bool okDefault = false,
    bool okDestructive = false,
    FixedExtentScrollController? controller,
    List<PickerActionWidgetBuilder>? actions,
    required IndexedWidgetBuilder make,
  }) async {
    final res = await navigator.push(
      CupertinoModalPopupRoute(
        builder: (ctx) => SoloPicker(
          make: make,
          count: count,
          controller: controller,
          ok: ok,
          targetHeight: targetHeight,
          okDefault: okDefault,
          okDestructive: okDestructive,
          actions: actions,
        ),
      ),
    );
    if (res is int) {
      return res;
    } else {
      assert(res == null, "return value is ${res.runtimeType} actually");
      return null;
    }
  }

  Future<(int, int)?> showDualPicker({
    required int countA,
    required int countB,
    String? ok,
    bool Function(int? selectedA, int? selectedB)? okEnabled,
    double targetHeight = 240,
    bool okDefault = false,
    bool okDestructive = false,
    FixedExtentScrollController? controllerA,
    FixedExtentScrollController? controllerB,
    List<DualPickerActionWidgetBuilder>? actions,
    required IndexedWidgetBuilder makeA,
    required IndexedWidgetBuilder makeB,
  }) async {
    final res = await navigator.push(
      CupertinoModalPopupRoute(
        builder: (ctx) => DualPicker(
          makeA: makeA,
          countA: countA,
          countB: countB,
          makeB: makeB,
          controllerA: controllerA,
          controllerB: controllerB,
          ok: ok,
          targetHeight: targetHeight,
          okDefault: okDefault,
          okDestructive: okDestructive,
          actions: actions,
        ),
      ),
    );
    if (res is (int, int)) {
      return res;
    } else {
      assert(res == null, "return value is ${res.runtimeType} actually");
      return null;
    }
  }
}

class SoloPicker extends StatefulWidget {
  final int count;
  final String? ok;
  final double targetHeight;
  final bool okDefault;
  final bool okDestructive;
  final FixedExtentScrollController? controller;
  final List<PickerActionWidgetBuilder>? actions;
  final IndexedWidgetBuilder make;

  const SoloPicker({
    super.key,
    required this.count,
    this.ok,
    this.controller,
    this.targetHeight = 240,
    this.okDefault = false,
    this.okDestructive = false,
    this.actions,
    required this.make,
  });

  @override
  State<SoloPicker> createState() => _SoloPickerState();
}

class _SoloPickerState extends State<SoloPicker> {
  late final $selected = ValueNotifier(widget.controller?.initialItem);

  @override
  void dispose() {
    $selected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ok = widget.ok;
    return CupertinoActionSheet(
      message: CupertinoPicker(
        scrollController: widget.controller,
        magnification: 1.22,
        useMagnifier: true,
        // This is called when selected item is changed.
        onSelectedItemChanged: (int selectedItem) {
          $selected.value = selectedItem;
        },
        squeeze: 1.5,
        itemExtent: 32.0,
        children: List<Widget>.generate(widget.count, (index) => widget.make(context, index)),
      ).sized(h: widget.targetHeight),
      actions: widget.actions
          ?.map(
              (e) => ValueListenableBuilder(valueListenable: $selected, builder: (ctx, value, child) => e(ctx, value)))
          .toList(),
      cancelButton: ok == null
          ? null
          : CupertinoActionSheetAction(
              onPressed: () {
                context.pop($selected.value);
              },
              isDefaultAction: widget.okDefault,
              isDestructiveAction: widget.okDestructive,
              child: ok.text(),
            ),
    );
  }
}

class DualPicker extends StatefulWidget {
  final FixedExtentScrollController? controllerA;
  final FixedExtentScrollController? controllerB;
  final int countA;
  final int countB;
  final String? ok;
  final bool okDefault;
  final bool okDestructive;
  final double targetHeight;
  final bool highlight;
  final List<DualPickerActionWidgetBuilder>? actions;
  final IndexedWidgetBuilder makeA;
  final IndexedWidgetBuilder makeB;

  const DualPicker({
    super.key,
    this.ok,
    this.actions,
    this.highlight = false,
    this.targetHeight = 240,
    this.controllerA,
    this.controllerB,
    required this.makeA,
    required this.countA,
    required this.countB,
    required this.makeB,
    this.okDefault = false,
    this.okDestructive = false,
  });

  @override
  State<DualPicker> createState() => _DualPickerState();
}

class _DualPickerState extends State<DualPicker> {
  late final $selectedA = ValueNotifier(widget.controllerA?.initialItem ?? 0);
  late final $selectedB = ValueNotifier(widget.controllerB?.initialItem ?? 0);

  @override
  void dispose() {
    $selectedA.dispose();
    $selectedB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ok = widget.ok;
    return CupertinoActionSheet(
      message: [
        CupertinoPicker(
          scrollController: widget.controllerA,
          magnification: 1.22,
          useMagnifier: true,
          // This is called when selected item is changed.
          onSelectedItemChanged: (int selectedItem) {
            $selectedA.value = selectedItem;
          },
          squeeze: 1.5,
          itemExtent: 32.0,
          children: List<Widget>.generate(widget.countA, (index) => widget.makeA(context, index)),
        ).expanded(),
        CupertinoPicker(
          scrollController: widget.controllerB,
          magnification: 1.22,
          useMagnifier: true,
          // This is called when selected item is changed.
          onSelectedItemChanged: (int selectedItem) {
            $selectedB.value = selectedItem;
          },
          squeeze: 1.5,
          itemExtent: 32.0,
          children: List<Widget>.generate(widget.countB, (index) => widget.makeB(context, index)),
        ).expanded(),
      ].row().sized(h: widget.targetHeight),
      actions: widget.actions?.map((e) => $selectedA >> (ctx, a) => $selectedB >> (ctx, b) => e(ctx, a, b)).toList(),
      cancelButton: ok == null
          ? null
          : CupertinoActionSheetAction(
              isDefaultAction: widget.okDefault,
              isDestructiveAction: widget.okDestructive,
              onPressed: () {
                context.pop(($selectedA.value, $selectedB.value));
              },
              child: ok.text(),
            ),
    );
  }
}

extension SnackBarX on BuildContext {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
    required Widget content,
    Duration duration = const Duration(milliseconds: 2000),
    SnackBarAction? action,
    VoidCallback? onVisible,
    bool? showCloseIcon = true,
    DismissDirection dismissDirection = DismissDirection.vertical,
  }) {
    final snackBar = SnackBar(
      content: content,
      duration: duration,
      action: action,
      onVisible: onVisible,
      showCloseIcon: showCloseIcon,
      dismissDirection: dismissDirection,
    );

    return ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}
