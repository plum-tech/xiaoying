import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/widget/common.dart';

class NotFoundPage extends StatelessWidget {
  final String routeName;

  const NotFoundPage(this.routeName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: "找不到页面".text()),
      body: LeavingBlank(icon: Icons.browser_not_supported, desc: "未找到请求的页面"),
    );
  }
}
