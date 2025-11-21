import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import '../i18n.dart';

Future<void> onFreshmanImport(BuildContext context) async {
  final confirm = await context.showDialogRequest(
    title: "不支持此功能",
    desc: "你目前使用的迎新系统账号无法导入课程表，请使用学号重新登录后重试",
    primary: "重新登录",
    secondary: i18n.cancel,
    dismissible: false,
  );
  if (confirm == true) {
    if (!context.mounted) return;
    context.push("/oa/login");
  }
}
