import 'package:flutter/material.dart';

extension AnimatedEx on Widget {
  Widget animatedSwitched({
    Duration duration = Durations.medium2,
    Curve? switchInCurve,
    Curve? switchOutCurve,
  }) =>
      AnimatedSwitcher(
        switchInCurve: switchInCurve ?? Curves.linear,
        switchOutCurve: switchOutCurve ?? Curves.linear,
        duration: duration,
        child: this,
      );

  Widget animatedSized({
    Duration duration = Durations.medium2,
    Alignment align = Alignment.center,
    Curve curve = Curves.fastEaseInToSlowEaseOut,
  }) =>
      AnimatedSize(
        curve: curve,
        duration: duration,
        alignment: align,
        child: this,
      );
}

class AnimatedSwitched extends StatelessWidget {
  final Duration duration;
  final Widget? child;
  final Curve switchInCurve;
  final Curve switchOutCurve;

  const AnimatedSwitched({
    super.key,
    this.duration = Durations.medium2,
    this.child,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: child ?? const SizedBox(),
    );
  }
}

class AnimatedShowUp extends StatelessWidget {
  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final bool when;
  final WidgetBuilder builder;

  const AnimatedShowUp({
    super.key,
    this.duration = Durations.medium2,
    required this.when,
    required this.builder,
    this.switchInCurve = Curves.linear,
    this.switchOutCurve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: when ? builder(context) : const SizedBox(),
    );
  }
}
