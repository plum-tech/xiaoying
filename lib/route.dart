import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/credentials/entity/login_status.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/init.dart';
import 'package:mimir/lifecycle.dart';
import 'package:mimir/school/exam_result/page/gpa.dart';
import 'package:mimir/school/exam_result/page/result.pg.dart';
import 'package:mimir/school/ywb/entity/service.dart';
import 'package:mimir/school/ywb/page/details.dart';
import 'package:mimir/school/ywb/page/service.dart';
import 'package:mimir/school/ywb/page/application.dart';
import 'package:mimir/settings/page/about.dart';
import 'package:mimir/settings/page/oa.dart';
import 'package:mimir/school/page/settings.dart';
import 'package:mimir/school/expense_records/page/records.dart';
import 'package:mimir/school/expense_records/page/statistics.dart';
import 'package:mimir/login/page/index.dart';
import 'package:mimir/settings/page/theme_color.dart';
import 'package:mimir/timetable/entity/timetable.dart';
import 'package:mimir/timetable/init.dart';
import 'package:mimir/timetable/p13n/page/cell_style.dart';
import 'package:mimir/timetable/page/edit/editor.dart';
import 'package:mimir/timetable/page/settings.dart';
import 'package:mimir/widget/inapp_webview/page.dart';
import 'package:mimir/widget/not_found.dart';
import 'package:mimir/school/oa_announce/entity/announce.dart';
import 'package:mimir/school/oa_announce/page/details.dart';
import 'package:mimir/school/exam_arrange/page/list.dart';
import 'package:mimir/school/oa_announce/page/list.dart';
import 'package:mimir/school/exam_result/page/result.ug.dart';
import 'package:mimir/settings/page/index.dart';
import 'package:mimir/school/index.dart';
import 'package:mimir/timetable/page/import.dart';
import 'package:mimir/timetable/page/index.dart';
import 'package:mimir/timetable/page/mine.dart';
import 'package:mimir/widget/image.dart';

final $TimetableShellKey = GlobalKey<NavigatorState>();
final $SchoolShellKey = GlobalKey<NavigatorState>();

bool isLoginGuarded(BuildContext ctx) {
  final loginStatus = ProviderScope.containerOf(ctx).read(CredentialsInit.storage.oa.$loginStatus);
  final credentials = ProviderScope.containerOf(ctx).read(CredentialsInit.storage.oa.$credentials);
  return loginStatus != OaLoginStatus.validated && credentials == null;
}

String? _loginRequired(BuildContext ctx, GoRouterState state) {
  if (isLoginGuarded(ctx)) return "/oa/login?guard=true";
  return null;
}

FutureOr<String?> _redirectRoot(BuildContext ctx, GoRouterState state) {
  // `ctx.riverpod().read(CredentialsInit.storage.oa.$loginStatus)` would return `LoginStatus.never` after just logged in.
  final loginStatus = CredentialsInit.storage.oa.loginStatus;
  if (loginStatus == OaLoginStatus.never) {
// allow to access settings page.
    if (state.matchedLocation.startsWith("/tools")) return null;
    if (state.matchedLocation.startsWith("/settings")) return null;
// allow to access mimir sign-in page
    if (state.matchedLocation.startsWith("/mimir/sign-in")) return null;
// allow to access webview page
    if (state.matchedLocation == "/webview") return null;
    return "/oa/login";
  }
  return null;
}

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
    path: "/timetable/import",
    builder: (ctx, state) => const ImportTimetablePage(),
    redirect: _loginRequired,
  ),
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
  GoRoute(
    path: "/timetable/cell-style",
    builder: (ctx, state) => const TimetableCellStyleEditor(),
  ),
];

final _schoolShellRoute = GoRoute(
  path: "/school",
  builder: (ctx, state) => const SchoolPage(),
);
final _settingsRoute = GoRoute(
  path: "/settings",
  builder: (ctx, state) => const SettingsPage(),
  routes: [
    GoRoute(
      path: "theme-color",
      builder: (ctx, state) => const ThemeColorPage(),
    ),
    GoRoute(
      path: "oa",
      redirect: (ctx, state) {
        if (CredentialsInit.storage.oa.credentials == null) {
          return "/oa/login";
        }
        return null;
      },
      builder: (ctx, state) => const OaSettingsPage(),
    ),
    GoRoute(
      path: "timetable",
      builder: (ctx, state) => const TimetableSettingsPage(),
    ),
    GoRoute(
      path: "school",
      builder: (ctx, state) => const SchoolSettingsPage(),
    ),
    GoRoute(
      path: "about",
      builder: (ctx, state) => const AboutSettingsPage(),
    ),
  ],
);
final _expenseRoute = GoRoute(
  path: "/expense-records",
  builder: (ctx, state) => const ExpenseRecordsPage(),
  redirect: _loginRequired,
  routes: [
    GoRoute(
      path: "statistics",
      builder: (ctx, state) => const ExpenseStatisticsPage(),
      redirect: _loginRequired,
    )
  ],
);

final _oaAnnounceRoute = GoRoute(
  path: "/oa/announcement",
  builder: (ctx, state) => const OaAnnounceListPage(),
  redirect: _loginRequired,
  routes: [
    // TODO: using path para
    GoRoute(
      path: "details",
      builder: (ctx, state) {
        final extra = state.extra;
        if (extra is OaAnnounceRecord) {
          return AnnounceDetailsPage(extra);
        }
        throw 404;
      },
    ),
  ],
);

final _ywbRoute = GoRoute(
  path: "/ywb",
  builder: (ctx, state) => const YwbServiceListPage(),
  redirect: _loginRequired,
  routes: [
    GoRoute(
      path: "mine",
      builder: (ctx, state) => const YwbMyApplicationListPage(),
    ),
    // TODO: using path para
    GoRoute(
      path: "details",
      builder: (ctx, state) {
        final extra = state.extra;
        if (extra is YwbService) {
          return YwbServiceDetailsPage(meta: extra);
        }
        throw 404;
      },
    ),
  ],
);

final _imageRoute = GoRoute(
  path: "/image",
  builder: (ctx, state) {
    final extra = state.extra;
    final data = state.uri.queryParameters["origin"] ?? extra as String?;
    if (data != null) {
      return ImageViewPage(
        data,
        title: state.uri.queryParameters["title"],
      );
    }
    throw 400;
  },
);

final _oaLoginRoute = GoRoute(
  path: "/oa/login",
  builder: (ctx, state) {
    final guarded = state.uri.queryParameters["guard"] == "true";
    return LoginPage(isGuarded: guarded);
  },
);

final _examArrange = GoRoute(
  path: "/exam/arrangement",
  builder: (ctx, state) => const ExamArrangementListPage(),
  redirect: _loginRequired,
);

final _examResultRoute = GoRoute(
  path: "/exam/result",
  routes: [
    GoRoute(
      path: "ug",
      builder: (ctx, state) => const ExamResultUgPage(),
      routes: [
        GoRoute(
          path: "gpa",
          builder: (ctx, state) => const GpaCalculatorPage(),
        ),
      ],
    ),
    GoRoute(
      path: "pg",
      builder: (ctx, state) => const ExamResultPgPage(),
    ),
  ],
  redirect: (ctx, state) {
    final redirect = _loginRequired(ctx, state);
    if (redirect != null) return redirect;
    if (state.fullPath == "/exam/result") {
      final currentUserType = CredentialsInit.storage.oa.userType;
      if (currentUserType == OaUserType.undergraduate) {
        return "/exam/result/ug";
      } else if (currentUserType == OaUserType.postgraduate) {
        return "/exam/result/ug";
      }
    }
    return null;
  },
);

final _webviewRoute = GoRoute(
  path: "/webview",
  builder: (ctx, state) {
    var url = state.uri.queryParameters["url"] ?? state.extra;
    if (url is String) {
      if (!url.startsWith("http://") && !url.startsWith("https://")) {
        url = "http://$url";
      }
      // return WebViewPage(initialUrl: url);
      return InAppWebViewPage(
        initialUri: WebUri(url),
        cookieJar: Init.cookieJar,
      );
    }
    throw 400;
  },
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

String _getRootRoute() {
  final available = [
    "/timetable",
    "/school",
  ];
  final userType = CredentialsInit.storage.oa.userType;
  if (userType == OaUserType.freshman) {
    return "/school";
  }
  return available.first;
}

RoutingConfig buildTimetableFocusRouter() {
  return RoutingConfig(
    redirect: _redirectRoot,
    routes: [
      GoRoute(
        path: "/",
        redirect: (ctx, state) => _getRootRoute(),
      ),
      _timetableShellRoute,
      ..._timetableRoutes,
      _schoolShellRoute,
      _webviewRoute,
      _expenseRoute,
      _settingsRoute,
      _oaAnnounceRoute,
      _ywbRoute,
      _examResultRoute,
      _examArrange,
      _oaLoginRoute,
      _imageRoute,
    ],
  );
}
