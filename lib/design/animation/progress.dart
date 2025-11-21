import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

class ProgressWatcher {
  double _progress;
  final void Function(double progress)? callback;

  ProgressWatcher({
    double initial = 0.0,
    this.callback,
  }) : _progress = initial;

  double get value => _progress;

  set value(double newV) {
    _progress = newV;
    callback?.call(newV);
  }
}

class AnimatedProgressBar extends StatelessWidget {
  final double? value;
  final Duration duration;

  const AnimatedProgressBar({
    super.key,
    this.value,
    this.duration = Durations.medium1,
  });

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    if (value == null) {
      return const LinearProgressIndicator();
    }
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeInOut,
      tween: Tween<double>(begin: 0, end: value),
      builder: (context, value, _) => LinearProgressIndicator(value: value),
    );
  }
}

class AnimatedProgressCircle extends StatelessWidget {
  final double? value;
  final Duration duration;

  const AnimatedProgressCircle({
    super.key,
    this.value,
    this.duration = Durations.medium1,
  });

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    if (value == null) {
      return const CircularProgressIndicator.adaptive();
    }
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeInOut,
      tween: Tween<double>(begin: value, end: value),
      builder: (context, value, _) => CircularProgressIndicator.adaptive(value: value),
    );
  }
}

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
        child: AbsorbPointer(
          absorbing: blocked,
          child: child,
        ),
      ),
      if (blocked && loading)
        Positioned.fill(
          child: const CircularProgressIndicator().center(),
        ),
    ].stack();
  }
}

class WhenLoading extends StatelessWidget {
  final bool loading;
  final Widget child;

  const WhenLoading({
    super.key,
    required this.child,
    this.loading = true,
  });

  @override
  Widget build(BuildContext context) {
    return [
      AnimatedOpacity(
        opacity: loading ? 0.5 : 1,
        duration: Durations.short4,
        child: child,
      ),
      if (loading)
        Positioned.fill(
          child: const CircularProgressIndicator().center(),
        ),
    ].stack();
  }
}
