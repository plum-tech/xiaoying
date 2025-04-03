import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:mimir/l10n/common.dart';

const _i18n = CaptchaI18n();

class CaptchaI18n with CommonI18nMixin {
  static const ns = "captcha";

  const CaptchaI18n();

  String get title => "$ns.title".tr();

  String get enterHint => "$ns.enterHint".tr();

  String get emptyInputError => "$ns.emptyInputError".tr();
}

class CaptchaSheetPage extends StatefulWidget {
  final Uint8List captchaData;

  const CaptchaSheetPage({
    super.key,
    required this.captchaData,
  });

  @override
  State<CaptchaSheetPage> createState() => _CaptchaSheetPageState();
}

class _CaptchaSheetPageState extends State<CaptchaSheetPage> {
  final $captcha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "Captcha".text(),
        actions: [
          PlatformTextButton(
            onPressed: () {
              context.navigator.pop($captcha.text);
            },
            child: "Submit".text(),
          )
        ],
      ),
      body: [
        Image.memory(
          widget.captchaData,
          scale: 0.5,
        ),
        $TextField$(
          controller: $captcha,
          autofocus: true,
          placeholder: _i18n.enterHint,
          keyboardType: TextInputType.text,
          autofillHints: const [AutofillHints.oneTimeCode],
          onSubmit: (value) {
            context.navigator.pop(value);
          },
        ).padOnly(t: 15),
      ].column(mas: MainAxisSize.min).center().padH(16),
    );
  }
}
