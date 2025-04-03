import 'package:flutter/material.dart';

class TooltipScope extends StatefulWidget {
  final String? message;
  final InlineSpan? richMessage;
  final Duration? showDuration;
  final Widget Function(
    BuildContext context,
    Widget trigger,
    Future<void> Function() showTooltip,
  ) builder;
  final Widget trigger;

  const TooltipScope({
    super.key,
    this.message,
    this.richMessage,
    this.showDuration,
    required this.trigger,
    required this.builder,
  });

  @override
  State<TooltipScope> createState() => _TooltipState();
}

class _TooltipState extends State<TooltipScope> {
  final $tooltip = GlobalKey<TooltipState>(debugLabel: "Tooltip");

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      buildTrigger(),
      showTooltip,
    );
  }

  Widget buildTrigger() {
    return Tooltip(
      key: $tooltip,
      message: widget.message,
      richMessage: widget.richMessage,
      showDuration: widget.showDuration,
      triggerMode: TooltipTriggerMode.tap,
      child: widget.trigger,
    );
  }

  Future<void> showTooltip() async {
    $tooltip.currentState?.ensureTooltipVisible();
    await Future.delayed(widget.showDuration ?? const Duration(milliseconds: 1500));
    Tooltip.dismissAllToolTips();
  }
}
