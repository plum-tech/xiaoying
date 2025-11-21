import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:version/version.dart';

enum AppPlatform {
  android("Android"),
  windows("Windows"),
  iOS("iOS"),
  macOS("macOS"),
  linux("Linux"),
  web("Web"),
  unknown("?");

  final String name;

  const AppPlatform(this.name);
}

class InstallerStore {
  // Android: general
  static const android = "com.android.packageinstaller";

  // Apple: Test Flight
  static const testFlight = "com.apple.testflight";

  // Apple: App Store
  static const appStore = "com.apple";

  // OPPO, Realme: 应用商店
  static const heytap = "com.heytap.market";

  // VIVO: 应用商店
  static const vivo = "com.bbk.appstore";

  // Xiaomi, Redmi: 纯净模式
  static const miui = "com.miui.packageinstaller";

  // Xiaomi, Redmi: 小米应用商店
  static const xiaomiMarket = "com.xiaomi.market";

  // Huawei: backup
  static const huaweiBackup = "com.huawei.localBackup";

  // Huawei: browser
  static const huaweiBrowser = "com.huawei.browser";
}

class AppMeta {
  final AppPlatform platform;
  final Version version;

  /// The app name. `CFBundleDisplayName` on iOS, `application/label` on Android.
  final String appName;

  /// The package name. `bundleIdentifier` on iOS, `getPackageName` on Android.
  final String packageName;

  /// The build signature. Empty string on iOS, signing key signature (hex) on Android.
  final String buildSignature;

  /// The installer store. Indicates through which store this application was installed.
  /// For example:
  /// com.apple.testflight
  final String? installerStore;

  const AppMeta({
    required this.platform,
    required this.version,
    required this.appName,
    required this.packageName,
    required this.buildSignature,
    required this.installerStore,
  });
}

Future<AppMeta> getCurrentVersion() async {
  final info = await PackageInfo.fromPlatform();
  var versionText = info.version;
  final String? buildNumber;
  if (info.buildNumber.isNotEmpty) {
    if (UniversalPlatform.isIOS && info.buildNumber == info.version) {
      buildNumber = null;
    } else {
      buildNumber = info.buildNumber;
    }
  } else {
    buildNumber = null;
  }
  if (buildNumber != null) {
    versionText = "${info.version}+$buildNumber";
  }

  final AppPlatform platform;
  if (UniversalPlatform.isAndroid) {
    platform = AppPlatform.android;
  } else if (UniversalPlatform.isIOS) {
    platform = AppPlatform.iOS;
  } else if (UniversalPlatform.isMacOS) {
    platform = AppPlatform.macOS;
  } else if (UniversalPlatform.isLinux) {
    platform = AppPlatform.linux;
  } else if (UniversalPlatform.isWindows) {
    platform = AppPlatform.windows;
  } else if (UniversalPlatform.isWeb) {
    platform = AppPlatform.web;
  } else {
    platform = AppPlatform.unknown;
  }
  return AppMeta(
    platform: platform,
    version: Version.parse(versionText),
    appName: info.appName,
    packageName: info.packageName,
    buildSignature: info.buildSignature,
    installerStore: info.installerStore,
  );
}

Future<BaseDeviceInfo> getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();
  if (UniversalPlatform.isAndroid) {
    return await deviceInfo.androidInfo;
  } else if (UniversalPlatform.isIOS) {
    return await deviceInfo.iosInfo;
  } else if (UniversalPlatform.isMacOS) {
    return await deviceInfo.macOsInfo;
  } else if (UniversalPlatform.isWindows) {
    return await deviceInfo.windowsInfo;
  } else if (UniversalPlatform.isLinux) {
    return await deviceInfo.linuxInfo;
  } else if (UniversalPlatform.isWeb) {
    return await deviceInfo.webBrowserInfo;
  } else {
    return BaseDeviceInfo({});
  }
}
