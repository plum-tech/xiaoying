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

  static const eduEmailDomain = "mail.sit.edu.cn";

  static String formatEduEmail({required String username}) {
    return "$username@$eduEmailDomain";
  }

  static const zhHansLocale = Locale.fromSubtags(languageCode: "zh", scriptCode: "Hans");
  static const defaultLocale = zhHansLocale;
  static const supportedLocales = [
    zhHansLocale,
  ];

  static final sitUri = Uri(scheme: "https", host: "sit.edu.cn");
  static final ugRegUri = Uri(scheme: "http", host: "jwxt.sit.edu.cn");
  static final pgRegUri = Uri(scheme: "http", host: "gms.sit.edu.cn");
  static final authServerUri = Uri(scheme: "https", host: "authserver.sit.edu.cn");
  static final class2ndUri = Uri(scheme: "http", host: "sc.sit.edu.cn");
  static final schoolCardUri = Uri(scheme: "http", host: "card.sit.edu.cn");
  static final myPortalUri = Uri(scheme: "https", host: "myportal.sit.edu.cn");
  static final libraryUri = Uri(scheme: "http", host: "210.35.66.106");
  static final ywbUri = Uri(scheme: "https", host: "ywb.sit.edu.cn");
  static final ywb2Uri = Uri(scheme: "https", host: "xgfy.sit.edu.cn");
  static final freshmanUri = Uri(scheme: "http", host: "freshman.sit.edu.cn");

  /// See [OpenLabDoorAppCard]
  static final gateUri = Uri(scheme: "http", host: "210.35.98.178");

  static final sitBehindCampusNetworkUriList = {
    ugRegUri,
    pgRegUri,
    schoolCardUri,
    libraryUri,
    ywbUri,
    freshmanUri,
  };
  static final sitUriList = {
    ...sitBehindCampusNetworkUriList,
    sitUri,
    authServerUri,
    class2ndUri,
    myPortalUri,
    ywb2Uri,
  };

  static final websiteUri = Uri(scheme: "https", host: "www.xiaoying.life");
}
