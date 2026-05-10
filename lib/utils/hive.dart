import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

final _log = Logger(
  printer: PrettyPrinter(
    methodCount: 8,
    // Number of method calls to be displayed
    errorMethodCount: 8,
    // Print an emoji for each log message
    dateTimeFormat: DateTimeFormat
        .onlyTimeAndSinceStart, // Should each log print contain a timestamp
  ),
);

extension BoxX on Box {
  T? safeGet<T>(dynamic key, {T? defaultValue}) {
    final value = get(key, defaultValue: defaultValue);
    if (value == null) return null;
    if (value is! T) {
      _log.e("[Box $name] $key is in ${value.runtimeType} but $T is expected.");
      return null;
    }
    return value;
  }

  Future<void> safePut<T>(dynamic key, T? value) async {
    await put(key, value);
  }
}

class BoxFieldNotifier<T> extends StateNotifier<T?> {
  final Listenable listenable;
  final T? Function() get;
  final FutureOr<void> Function(T? v) set;

  BoxFieldNotifier(super._state, this.listenable, this.get, this.set) {
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

class BoxFieldWithDefaultNotifier<T> extends StateNotifier<T> {
  final Listenable listenable;
  final T? Function() get;
  final T Function() getDefault;
  final FutureOr<void> Function(T v) set;

  BoxFieldWithDefaultNotifier(
    super._state,
    this.listenable,
    this.get,
    this.set,
    this.getDefault,
  ) {
    listenable.addListener(_refresh);
  }

  void _refresh() {
    state = get() ?? getDefault();
  }

  @override
  void dispose() {
    listenable.removeListener(_refresh);
    super.dispose();
  }
}

extension BoxProviderX on Box {
  /// For generic class, like [List] or [Map], please specify the [get] for type conversion.
  StateNotifierProvider<BoxFieldNotifier<T>, T?> provider<T>(
    dynamic key, {
    T? Function()? get,
    FutureOr<void> Function(T? v)? set,
  }) {
    return StateNotifierProvider<BoxFieldNotifier<T>, T?>((ref) {
      return BoxFieldNotifier(
        get != null ? get.call() : safeGet<T>(key),
        listenable(keys: [key]),
        () => get != null ? get.call() : safeGet<T>(key),
        (v) => set != null ? set.call(v) : safePut<T>(key, v),
      );
    });
  }

  /// For generic class, like [List] or [Map], please specify the [get] for type conversion.
  StateNotifierProvider<BoxFieldWithDefaultNotifier<T>, T>
  providerWithDefault<T>(
    dynamic key,
    T Function() getDefault, {
    T? Function()? get,
    FutureOr<void> Function(T v)? set,
  }) {
    return StateNotifierProvider<BoxFieldWithDefaultNotifier<T>, T>((ref) {
      return BoxFieldWithDefaultNotifier(
        (get != null ? get.call() : safeGet<T>(key)) ?? getDefault(),
        listenable(keys: [key]),
        () => get != null ? get.call() : safeGet<T>(key),
        (v) => set != null ? set.call(v) : safePut<T>(key, v),
        getDefault,
      );
    });
  }

  /// For generic class, like [List] or [Map], please specify the [get] for type conversion.
  StateNotifierProviderFamily<BoxFieldNotifier<T>, T?, Arg>
  providerFamily<T, Arg>(
    dynamic Function(Arg arg) keyOf, {
    T? Function(Arg arg)? get,
    FutureOr<void> Function(Arg arg, T? v)? set,
  }) {
    return StateNotifierProvider.family<BoxFieldNotifier<T>, T?, Arg>((
      ref,
      arg,
    ) {
      return BoxFieldNotifier(
        get != null ? get.call(arg) : safeGet<T>(arg),
        listenable(keys: [keyOf(arg)]),
        () => get != null ? get.call(arg) : safeGet<T>(arg),
        (v) => set != null ? set.call(arg, v) : safePut<T>(arg, v),
      );
    });
  }
}
