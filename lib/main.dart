import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mimir/files.dart';
import 'package:mimir/storage/hive/init.dart';
import 'package:mimir/init.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mimir/entity/meta.dart';
import 'package:mimir/storage/prefs.dart';
import 'package:mimir/utils/error.dart';
import 'package:system_theme/system_theme.dart';
import 'package:uuid/uuid.dart';

import 'app.dart';

import 'l10n/yaml_assets_loader.dart';
import 'r.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debugRepaintRainbowEnabled = true;
  // debugRepaintTextRainbowEnabled = true;
  // debugPaintSizeEnabled = true;
  GoRouter.optionURLReflectsImperativeAPIs = kDebugMode;
  if (kDebugMode && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  final prefs = await SharedPreferences.getInstance();
  final uuid = prefs.getUuid();
  if (uuid == null) {
    final newUuid = const Uuid().v4();
    await prefs.setUuid(newUuid);
    R.uuid = newUuid;
  } else {
    R.uuid = uuid;
  }

  // Initialize the window size before others for a better experience when loading.
  try {
    await SystemTheme.accentColor.load();
  } catch (error, stackTrace) {
    debugPrintError(error, stackTrace);
  }
  await EasyLocalization.ensureInitialized();

  await Files.init(
    temp: await getTemporaryDirectory(),
    cache: await getApplicationCacheDirectory(),
    internal: await getApplicationSupportDirectory(),
    user: await getApplicationDocumentsDirectory(),
  );
  // Perform migrations
  R.meta = await getCurrentVersion();
  // Initialize Hive
  await HiveInit.initLocalStorage(
    coreDir: Files.internal.subDir("hive", R.hiveStorageVersionCore),
    // iOS will clear the cache under [getApplicationCacheDirectory()] when device has no enough storage.
    cacheDir: Files.internal.subDir("hive-cache", R.hiveStorageVersionCache),
  );
  HiveInit.initAdapters();
  await HiveInit.initBox();

  // Setup Settings and Meta

  R.deviceInfo = await getDeviceInfo();
  Init.registerCustomEditor();
  await Init.initNetwork();
  await Init.initModules();
  await Init.initStorage();
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: R.supportedLocales,
        path: 'assets/l10n',
        fallbackLocale: R.defaultLocale,
        useFallbackTranslations: true,
        assetLoader: _yamlAssetsLoader,
        child: const MimirApp(),
      ),
    ),
  );
}

final _yamlAssetsLoader = YamlAssetLoader();
