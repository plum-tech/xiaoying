import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mimir/design/adaptive/foundation.dart';
import 'package:rettulf/rettulf.dart';

class CaptchaDialog extends StatefulWidget {
  final Uint8List captchaData;

  const CaptchaDialog({super.key, required this.captchaData});

  @override
  State<CaptchaDialog> createState() => _CaptchaDialogState();
}

class _CaptchaDialogState extends State<CaptchaDialog> {
  final $captcha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return $Dialog$(
      title: "验证码",
      primary: $Action$(
        text: "提交",
        warning: true,
        isDefault: true,
        onPressed: () {
          context.navigator.pop($captcha.text);
        },
      ),
      secondary: $Action$(
        text: "取消",
        onPressed: () {
          context.navigator.pop(null);
        },
      ),
      desc: (ctx) => [
        Image.memory(widget.captchaData, scale: 0.5),
        $TextField$(
          controller: $captcha,
          autofocus: true,
          placeholder: "请输入验证码",
          keyboardType: TextInputType.text,
          autofillHints: const [AutofillHints.oneTimeCode],
          onSubmit: (value) {
            context.navigator.pop(value);
          },
        ).padOnly(t: 15),
      ].column(mas: MainAxisSize.min).padAll(5),
    );
  }

  @override
  void dispose() {
    super.dispose();
    $captcha.dispose();
  }
}
