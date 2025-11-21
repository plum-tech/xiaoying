import 'package:flutter/material.dart';

class AnimatedNumber extends StatelessWidget {
  final Duration duration;
  final num value;
  final Widget Function(BuildContext context, double value) builder;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.builder = _kBuild,
    this.duration = Durations.medium3,
  });

  static Widget _kBuild(BuildContext context, double value) {
    return Text("$value");
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: value, end: value),
      duration: duration,
      builder: (ctx, value, _) => builder(ctx, value.toDouble()),
    );
  }
}
