import 'dart:math';

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/agreements/entity/agreements.dart';
import 'package:mimir/agreements/page/privacy_policy.dart';
import 'package:mimir/lifecycle.dart';
import 'package:mimir/r.dart';
import 'package:mimir/router.dart';
import 'package:mimir/settings/settings.dart';
import 'package:universal_platform/universal_platform.dart';

class MimirApp extends ConsumerStatefulWidget {
  const MimirApp({super.key});

  @override
  ConsumerState<MimirApp> createState() => _MimirAppState();
}

class _MimirAppState extends ConsumerState<MimirApp> {
  final $routingConfig = ValueNotifier(buildTimetableFocusRouter());
  late final router = buildRouter($routingConfig);

  @override
  void initState() {
    super.initState();
    if (UniversalPlatform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));
      SystemChrome.setEnabledSystemUIMode(.edgeToEdge);
    }
  }

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData bakeTheme(ThemeData origin) {
      return origin.copyWith(
        platform: R.debugCupertino ? TargetPlatform.iOS : null,
        menuTheme: MenuThemeData(
          style: (origin.menuTheme.style ?? const MenuStyle()).copyWith(
            shape: WidgetStatePropertyAll<OutlinedBorder?>(RoundedRectangleBorder(borderRadius: .circular(12.0))),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: _randomColor(R.uuid.hashCode), brightness: origin.brightness),
        visualDensity: VisualDensity.comfortable,
        splashFactory: InkSparkle.splashFactory,
        navigationBarTheme: const NavigationBarThemeData(height: 60),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            .android: ZoomPageTransitionsBuilder(),
            .iOS: CupertinoPageTransitionsBuilder(),
            .macOS: CupertinoPageTransitionsBuilder(),
            .linux: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.vertical),
            .windows: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.vertical),
          },
        ),
      );
    }

    return MaterialApp.router(
      title: R.appName,
      onGenerateTitle: (ctx) => "appName".tr(),
      routerConfig: router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode: .system,
      theme: bakeTheme(.light()),
      darkTheme: bakeTheme(.dark()),
      builder: (ctx, child) =>
          _PostServiceRunner(key: const ValueKey("Post service runner"), child: child ?? const SizedBox.shrink()),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {.mouse, .touch, .stylus, .trackpad, .unknown},
      ),
    );
  }
}

Color _randomColor(int seed) {
  final rand = Random(seed);
  return Color.fromRGBO(rand.nextInt(256), rand.nextInt(256), rand.nextInt(256), 1);
}

class _PostServiceRunner extends ConsumerStatefulWidget {
  final Widget child;

  const _PostServiceRunner({super.key, required this.child});

  @override
  ConsumerState<_PostServiceRunner> createState() => _PostServiceRunnerState();
}

class _PostServiceRunnerState extends ConsumerState<_PostServiceRunner> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final navigateCtx = $key.currentContext;
      if (navigateCtx == null) return;
      final accepted = ref.read(Settings.agreements.$basicAcceptanceOf(AgreementVersion.current));
      if (accepted == true) return;
      await AgreementsAcceptanceSheet.show(navigateCtx);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
