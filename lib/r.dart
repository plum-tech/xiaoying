import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:mimir/entity/meta.dart';

class R {
  const R._();

  static const scheme = "xiaoying";
  static const hiveStorageVersionCache = "2.7.0";
  static const hiveStorageVersionCore = "2.1.1";
  static const appId = "net.liplum.mimir_trial";
  static const appName = "Xiao Ying Trial";

  static String get appNameL10n => "appName".tr();

  static late AppMeta meta;
  static BaseDeviceInfo? deviceInfo;
  static late String uuid;

  /// For debugging iOS on other platforms.
  static const debugCupertino = kDebugMode ? false : false;

  static const debugNetwork = true;
  static const debugAllFeatures = false;
  static const poorNetworkSimulation = false;

  /// The default window size is small enough for any modern desktop device.
  static const Size defaultWindowSize = Size(500, 800);

  /// If the window was resized to too small accidentally, this will keep a minimum function area.
  static const Size minWindowSize = Size(300, 400);

  static const zhHansLocale = Locale.fromSubtags(languageCode: "zh", scriptCode: "Hans");
  static const defaultLocale = zhHansLocale;
  static const supportedLocales = [
    zhHansLocale,
  ];

  static final websiteUri = Uri(scheme: "https", host: "www.xiaoying.life");
}
