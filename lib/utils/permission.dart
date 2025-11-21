import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/l10n/common.dart';
import 'package:universal_platform/universal_platform.dart';

Future<bool> ensurePermission(Permission permission) async {
  PermissionStatus status = await permission.status;

  if (status != PermissionStatus.granted) {
    status = await Permission.storage.request();
  }
  return status == PermissionStatus.granted;
}

class PermissionI18n with CommonI18nMixin {
  const PermissionI18n();

  static const _ns = "permission";

  String get permissionDenied => "$_ns.permissionDenied".tr();

  String permissionDeniedDescOf(Permission permission) => "$_ns.permissionDeniedDescOf".tr(args: [
        permission.l10n(),
      ]);

  String permissionRequestOf(Permission permission) => "$_ns.permissionRequestOf".tr(args: [
        permission.l10n(),
      ]);

  String usageOf(Permission permission) => "$_ns.usage.${permission.name}".tr();

  String get goSettings => "$_ns.goSettings".tr();
}

extension PermissionI18nX on Permission {
  String l10n() => "${PermissionI18n._ns}.type.$name".tr();

  String get name => toString().substring(11);
}

const _i = PermissionI18n();

Future<void> showPermissionDeniedDialog(
  BuildContext context,
  Permission permission,
) async {
  final confirm = await context.showDialogRequest(
    title: _i.permissionDenied,
    desc: _i.permissionDeniedDescOf(permission),
    primary: _i.goSettings,
    secondary: _i.cancel,
  );
  if (confirm == true) {
    await AppSettings.openAppSettings(type: AppSettingsType.settings);
  }
}

Future<bool> requestPermission(BuildContext context, Permission permission) async {
  if (UniversalPlatform.isIOS) return true;
  final isPermissionGranted = await permission.isGranted;
  if (isPermissionGranted) return true;
  if (!context.mounted) return false;
  await context.showTip(
    title: _i.permissionRequestOf(permission),
    desc: _i.usageOf(permission),
    primary: _i.ok,
  );
  final res = await permission.request();
  return res.isGranted;
}
