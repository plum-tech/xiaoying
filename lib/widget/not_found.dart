import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/widget/common.dart';

class NotFoundPage extends StatelessWidget {
  final String routeName;

  const NotFoundPage(this.routeName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _i18n.title.text(),
      ),
      body: LeavingBlank(
        icon: Icons.browser_not_supported,
        desc: _i18n.subtitle,
      ),
    );
  }
}

const _i18n = _I18n();

class _I18n {
  const _I18n();

  static const ns = "404";

  String get title => "$ns.title".tr();

  String get subtitle => "$ns.subtitle".tr();
}
