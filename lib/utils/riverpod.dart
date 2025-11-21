import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension BuildContextRiverpodX on BuildContext {
  ProviderContainer riverpod({
    bool listen = true,
  }) =>
      ProviderScope.containerOf(
        this,
        listen: listen,
      );
}

class ListenableStateNotifier<T> extends StateNotifier<T> {
  final Listenable listenable;
  final T Function() get;
  final void Function(T v)? set;

  ListenableStateNotifier(super._state, this.listenable, this.get, this.set) {
    listenable.addListener(_refresh);
  }

  void _refresh() {
    state = get();
  }

  @override
  void dispose() {
    listenable.removeListener(_refresh);
    super.dispose();
  }
}

extension ListenableRiverpodX on Listenable {
  StateNotifierProvider<ListenableStateNotifier<T>, T> provider<T>({
    required T Function() get,
    void Function(T v)? set,
  }) {
    return StateNotifierProvider<ListenableStateNotifier<T>, T>((ref) {
      return ListenableStateNotifier(
        get(),
        this,
        get,
        set,
      );
    });
  }
}
