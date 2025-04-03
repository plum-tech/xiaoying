import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StateNotifierBuilder<T> extends StatefulWidget {
  final StateNotifier<T> notifier;
  final ValueWidgetBuilder<T> builder;
  final Widget? child;

  const StateNotifierBuilder({
    super.key,
    required this.notifier,
    this.child,
    required this.builder,
  });

  @override
  State<StateNotifierBuilder<T>> createState() => _StateNotifierBuilderState<T>();
}

class _StateNotifierBuilderState<T> extends State<StateNotifierBuilder<T>> {
  late RemoveListener removeListener;

  @override
  void initState() {
    super.initState();
    removeListener = widget.notifier.addListener(rebuild);
  }

  @override
  void dispose() {
    removeListener();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StateNotifierBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      removeListener();
      removeListener = widget.notifier.addListener(rebuild);
    }
  }

  void rebuild(T state) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      widget.notifier.state,
      widget.child,
    );
  }
}

extension RettulfValueListenableX<T> on StateNotifier<T> {
  /// see [StateNotifierBuilder]
  StateNotifierBuilder<T> operator >>(
    Widget Function(BuildContext context, T value) builder,
  ) =>
      StateNotifierBuilder(
        notifier: this,
        builder: (context, value, child) => builder(context, value),
      );
}
