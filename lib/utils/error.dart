import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mimir/credentials/error.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/lifecycle.dart';
import 'package:mimir/login/i18n.dart';

void debugPrintError(Object? error, [StackTrace? stackTrace]) {
  if (error == null) {
    return;
  } else if (error is DioException) {
    debugPrint(error.toString());
    debugPrintStack(stackTrace: error.stackTrace, maxFrames: 10);
  } else if (error is AsyncError) {
    debugPrintError(error.error, error.stackTrace);
  } else if (error is ParallelWaitError) {
    final errors = error.errors;
    if (errors is (AsyncError?, AsyncError?)) {
      debugPrintError(errors.$1);
      debugPrintError(errors.$2);
    } else {
      debugPrint(errors.toString());
    }
  } else {
    debugPrint(error.toString());
    debugPrintStack(stackTrace: stackTrace);
  }
}

const _i18n = CommonAuthI18n();

Future<void> handleRequestError(Object? error, [StackTrace? stackTrace]) async {
  debugPrintError(error, stackTrace);
  final context = $key.currentContext;
  if (error is CredentialException) {
    if (context == null || context.mounted) return;
    await context.showTip(
      serious: true,
      title: _i18n.failedWarn,
      desc: error.type.l10n(),
      primary: _i18n.close,
    );
    return;
  }
}
