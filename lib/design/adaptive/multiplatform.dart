import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mimir/r.dart';
import 'package:universal_platform/universal_platform.dart';

bool get isCupertino => R.debugCupertino || UniversalPlatform.isIOS || UniversalPlatform.isMacOS;

bool get supportContextMenu =>
    kIsWeb || UniversalPlatform.isIOS || UniversalPlatform.isMacOS || UniversalPlatform.isDesktop || R.debugCupertino;

extension ShareX on BuildContext {
  Rect? getSharePositionOrigin() {
    final box = findRenderObject() as RenderBox?;
    final sharePositionOrigin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    if (UniversalPlatform.isIOS || UniversalPlatform.isMacOS) {
      assert(sharePositionOrigin != null, "sharePositionOrigin should be nonnull on iPad and macOS");
    }
    return sharePositionOrigin;
  }
}

extension BuildContextPlatformIconsX on BuildContext {
  PlatformIcons get icons => PlatformIcons(this);
}

extension PlatformIconsX on PlatformIcons {
  IconData get lock => isMaterial(context) ? Icons.lock : CupertinoIcons.lock;

  IconData get unlock => isMaterial(context) ? Icons.lock_open : CupertinoIcons.lock_open;

  IconData get copy => isMaterial(context) ? Icons.copy : CupertinoIcons.plus_square_on_square;

  IconData get calendar => isMaterial(context) ? Icons.calendar_month : CupertinoIcons.calendar;

  IconData get qrcode => isMaterial(context) ? Icons.qr_code : CupertinoIcons.qrcode;

  IconData get preview => isMaterial(context) ? Icons.preview : CupertinoIcons.eye;

  IconData get warningFilled => isMaterial(context) ? Icons.error : CupertinoIcons.exclamationmark_circle_fill;

  IconData get warning => isMaterial(context) ? Icons.error_outline : CupertinoIcons.exclamationmark_circle;

  IconData get info => isMaterial(context) ? Icons.info : CupertinoIcons.info;

  IconData get troubleshoot => isMaterial(context) ? Icons.troubleshoot : CupertinoIcons.wrench;

  IconData get backspace => isMaterial(context) ? Icons.keyboard_backspace : CupertinoIcons.delete_left;

  IconData get return_ => isMaterial(context) ? Icons.keyboard_return : CupertinoIcons.return_icon;

  IconData get game => isMaterial(context) ? Icons.videogame_asset_outlined : CupertinoIcons.gamecontroller;

  IconData get gameFilled => isMaterial(context) ? Icons.videogame_asset : CupertinoIcons.gamecontroller_fill;

  IconData get global => isMaterial(context) ? Icons.public : CupertinoIcons.globe;

  IconData get sun => isMaterial(context) ? Icons.light_mode : CupertinoIcons.sun_max;

  IconData get moon => isMaterial(context) ? Icons.dark_mode : CupertinoIcons.moon;

  IconData get close => isMaterial(context) ? Icons.close : CupertinoIcons.clear;
}
