import 'package:flutter/material.dart';
import 'package:mimir/design/adaptive/editor.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/timetable/init.dart';

class Init {
  const Init._();

  static Future<void> initNetwork() async {}

  static Future<void> initModules() async {
    debugPrint("Initializing modules");
  }

  static Future<void> initStorage() async {
    debugPrint("Initializing module storage");
    TimetableInit.initStorage();
  }

  static void registerCustomEditor() {
    EditorEx.registerEnumEditor(Campus.values);
    EditorEx.registerEnumEditor(ThemeMode.values);
  }
}
