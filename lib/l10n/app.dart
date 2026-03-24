import 'package:mimir/timetable/i18n.dart' as t;

class AppI18n {
  const AppI18n();
  final navigation = const _Navigation();
}

class _Navigation {
  const _Navigation();

  String get timetable => t.i18n.navigation;
}
