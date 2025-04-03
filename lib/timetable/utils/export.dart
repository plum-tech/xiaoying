import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/files.dart';
import 'package:sanitize_filename/sanitize_filename.dart';
import 'package:share_plus/share_plus.dart';

import '../entity/timetable.dart';

Future<void> exportTimetableFileAndShare(
  Timetable timetable, {
  required BuildContext context,
}) async {
  final content = jsonEncode(timetable.toJson());
  var fileName = "${timetable.name}.timetable";
  if (timetable.signature.isNotEmpty) {
    fileName = "${timetable.signature} $fileName";
  }
  fileName = sanitizeFilename(fileName, replacement: "-");
  final timetableFi = Files.temp.subFile(fileName);
  final sharePositionOrigin = context.getSharePositionOrigin();
  await timetableFi.writeAsString(content);
  await Share.shareXFiles(
    [XFile(timetableFi.path)],
    sharePositionOrigin: sharePositionOrigin,
  );
}
