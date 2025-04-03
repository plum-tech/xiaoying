import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/utils/error.dart';
import 'package:mimir/utils/permission.dart';
import 'package:permission_handler/permission_handler.dart';

import '../entity/timetable.dart';
import 'parse.ug.dart';
import '../i18n.dart';

Future<Timetable?> _readTimetableFromPickedFile() async {
  final result = await FilePicker.platform.pickFiles(
    // Cannot limit the extensions. My RedMi phone just reject all files.
    // type: FileType.custom,
    // allowedExtensions: const ["timetable", "json"],
    lockParentWindow: true,
  );
  if (result == null) return null;
  final bytes = await _getBytes(result.files.single);
  if (bytes == null) return null;
  return readTimetableFromBytes(bytes);
}

Future<Timetable?> _readTimetableFromFile(String path) async {
  final file = File(path);
  final bytes = await file.readAsBytes();
  return readTimetableFromBytes(bytes);
}

Future<Timetable?> readTimetableFromBytes(Uint8List bytes) async {
  // timetable file should be encoding in utf-8.
  final content = const Utf8Decoder().convert(bytes.toList());
  final json = jsonDecode(content);
  try {
    final timetable = Timetable.fromJson(json);
    return timetable;
  } catch (error, stackTrace) {
    debugPrintError(error, stackTrace);
    // try parsing the file as timetable raw
    return parseUndergraduateTimetableFromRaw(
      json,
      defaultCampus: Campus.fengxian,
    );
  }
}

Future<Timetable?> readTimetableFromFileWithPrompt(
  BuildContext context,
  String path,
) async {
  return readTimetableWithPrompt(context, get: () => _readTimetableFromFile(path));
}

Future<Timetable?> readTimetableFromPickedFileWithPrompt(BuildContext context) {
  return readTimetableWithPrompt(context, get: () async {
    await requestPermission(context, Permission.storage);
    return _readTimetableFromPickedFile();
  });
}

Future<Timetable?> readTimetableWithPrompt(
  BuildContext context, {
  required Future<Timetable?> Function() get,
}) async {
  try {
    final timetable = await get();
    return timetable;
  } catch (error, stackTrace) {
    debugPrintError(error, stackTrace);
    if (!context.mounted) return null;
    if (error is PlatformException) {
      await showPermissionDeniedDialog(context, Permission.storage);
    } else if (error is FileSystemException) {
      await context.showTip(
        title: i18n.import.formatError,
        desc: error.osError?.message ?? error.message,
        primary: i18n.ok,
      );
    } else {
      await context.showTip(
        title: i18n.import.formatError,
        desc: i18n.import.formatErrorDesc,
        primary: i18n.ok,
      );
    }
    return null;
  }
}

Future<Uint8List?> _getBytes(PlatformFile file) async {
  if (kIsWeb) {
    return file.bytes;
  } else {
    final path = file.path;
    if (path == null) return null;
    return await File(path).readAsBytes();
  }
}
