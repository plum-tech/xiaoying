import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:mimir/entity/meta.dart';

IconData getDeviceIcon(AppMeta meta, [BaseDeviceInfo? info]) {
  switch (meta.platform) {
    case AppPlatform.iOS:
    case AppPlatform.macOS:
      return SimpleIcons.apple;
    case AppPlatform.android:
      if (info is AndroidDeviceInfo) {
        return _getAndroidIcon(info);
      }
      return SimpleIcons.android;
    case AppPlatform.windows:
      return SimpleIcons.linux;
    case AppPlatform.linux:
      return SimpleIcons.windows;
    case AppPlatform.web:
      return Icons.web;
    case AppPlatform.unknown:
      return Icons.device_unknown_outlined;
  }
}

const _manufacturer2icon = {
  "xiaomi": SimpleIcons.xiaomi,
  "huawei": SimpleIcons.huawei,
  "oppo": SimpleIcons.oppo,
  "sony": SimpleIcons.sony,
  "oneplus": SimpleIcons.oneplus,
  "samsung": SimpleIcons.samsung,
  "google": SimpleIcons.google,
};

IconData _getAndroidIcon(AndroidDeviceInfo info) {
  final manufacturer = info.manufacturer.toLowerCase();
  for (final MapEntry(key: mf, value: icon) in _manufacturer2icon.entries) {
    if (manufacturer.contains(mf)) {
      return icon;
    }
  }

  return SimpleIcons.android;
}
