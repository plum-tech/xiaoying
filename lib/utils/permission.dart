import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:permission_handler/permission_handler.dart';

String _permissionName(Permission permission) =>
    permission.toString().substring(11);

String _permissionLabel(Permission permission) {
  return switch (_permissionName(permission)) {
    "storage" => "存储",
    "camera" => "相机",
    "photos" => "相册",
    _ => "相关",
  };
}

Future<void> showPermissionDeniedDialog(
  BuildContext context,
  Permission permission,
) async {
  final confirm = await context.showDialogRequest(
    title: "没有权限",
    desc: "${_permissionLabel(permission)}权限未被授权，请检查应用的设置。",
    primary: "前往设置",
    secondary: "取消",
  );
  if (confirm == true) {
    await AppSettings.openAppSettings(type: AppSettingsType.settings);
  }
}
