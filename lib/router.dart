import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/lifecycle.dart';
import 'package:mimir/settings/page/about.dart';
import 'package:mimir/timetable/entity/timetable.dart';
import 'package:mimir/timetable/init.dart';
import 'package:mimir/timetable/page/edit/editor.dart';
import 'package:mimir/timetable/page/settings.dart';
import 'package:mimir/widget/not_found.dart';
import 'package:mimir/settings/page/index.dart';
import 'package:mimir/timetable/page/index.dart';
import 'package:mimir/timetable/page/mine.dart';

import 'index.dart';

Widget _onError(BuildContext context, GoRouterState state) {
  return NotFoundPage(state.uri.toString());
}

final _timetableShellRoute = GoRoute(
  path: "/timetable",
// Timetable is the home page.
  builder: (ctx, state) => const TimetablePage(),
);

Timetable? _getTimetable(GoRouterState state) {
  final extra = state.extra;
  if (extra is Timetable) return extra;
  final uuid = state.pathParameters["uuid"] ?? "";
  final timetable = TimetableInit.storage.timetable[uuid];
  return timetable;
}

final _timetableRoutes = [
  GoRoute(
    path: "/timetable/mine",
    builder: (ctx, state) => const MyTimetableListPage(),
  ),
  GoRoute(
    path: "/timetable/edit/:uuid",
    builder: (ctx, state) {
      final timetable = _getTimetable(state);
      if (timetable == null) throw 404;
      return TimetableEditorPage(timetable: timetable);
    },
  ),
];

final _settingsRoute = GoRoute(
  path: "/settings",
  builder: (ctx, state) => const SettingsPage(),
  routes: [
    GoRoute(
      path: "timetable",
      builder: (ctx, state) => const TimetableSettingsPage(),
    ),
    GoRoute(
      path: "about",
      builder: (ctx, state) => const AboutSettingsPage(),
    ),
  ],
);

GoRouter buildRouter(ValueNotifier<RoutingConfig> $routingConfig) {
  return GoRouter.routingConfig(
    routingConfig: $routingConfig,
    navigatorKey: $key,
    initialLocation: "/",
    debugLogDiagnostics: kDebugMode,
    // onException: _onException,
    errorBuilder: _onError,
  );
}

RoutingConfig buildTimetableFocusRouter() {
  return RoutingConfig(
    routes: [
      GoRoute(
        path: "/",
        redirect: (ctx, state) => "/timetable",
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainStagePage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [_timetableShellRoute],
          ),
        ],
      ),
      ..._timetableRoutes,
      _settingsRoute,
    ],
  );
}
