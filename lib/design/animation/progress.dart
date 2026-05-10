import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

class BlockWhenLoading extends StatelessWidget {
  final bool blocked;
  final bool loading;
  final Widget child;

  const BlockWhenLoading({
    super.key,
    required this.blocked,
    required this.child,
    this.loading = true,
  });

  @override
  Widget build(BuildContext context) {
    return [
      AnimatedOpacity(
        opacity: blocked ? 0.5 : 1,
        duration: Durations.short4,
        child: AbsorbPointer(absorbing: blocked, child: child),
      ),
      if (blocked && loading)
        Positioned.fill(child: const CircularProgressIndicator().center()),
    ].stack();
  }
}
