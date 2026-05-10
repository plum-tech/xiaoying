import 'package:flutter/material.dart';
import 'package:mimir/design/adaptive/foundation.dart';

import '../entity/timetable.dart';
import 'edit/editor.dart';

Future<Timetable?> processImportedTimetable(
  BuildContext context,
  Timetable timetable, {
  bool useRootNavigator = false,
}) async {
  final newTimetable = await context.showSheet<Timetable>(
    (ctx) => TimetableEditorPage(timetable: timetable),
    dismissible: false,
  );
  return newTimetable;
}
