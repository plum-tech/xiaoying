import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:universal_platform/universal_platform.dart';

Future<bool> ensurePermission(Permission permission) async {
  PermissionStatus status = await permission.status;

  if (status != PermissionStatus.granted) {
    status = await Permission.storage.request();
  }
  return status == PermissionStatus.granted;
}

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

String _permissionUsage(Permission permission) {
  return switch (_permissionName(permission)) {
    "storage" => "小应生活需要存储权限来读取和写入课程表文件",
    "camera" => "小应生活需要相机权限来扫描二维码",
    "photos" => "小应生活需要相册权限来从图像中扫描二维码",
    _ => "小应生活需要相关权限来正常使用功能",
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

Future<bool> requestPermission(
  BuildContext context,
  Permission permission,
) async {
  if (UniversalPlatform.isIOS) return true;
  final isPermissionGranted = await permission.isGranted;
  if (isPermissionGranted) return true;
  if (!context.mounted) return false;
  await context.showTip(
    title: "需要${_permissionLabel(permission)}权限",
    desc: _permissionUsage(permission),
    primary: "好的",
  );
  final res = await permission.request();
  return res.isGranted;
}
