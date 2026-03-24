import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

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
