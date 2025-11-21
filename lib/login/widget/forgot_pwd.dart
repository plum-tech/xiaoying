import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/utils/guard_launch.dart';
import '../i18n.dart';

const _i18n = OaLoginI18n();

class ForgotPasswordButton extends StatelessWidget {
  final String url;

  const ForgotPasswordButton({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformTextButton(
      child: _i18n.forgotPwd.text(
        style: const TextStyle(color: Colors.grey),
      ),
      onPressed: () async {
        await guardLaunchUrlString(context, url);
      },
    );
  }
}
