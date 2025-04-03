import 'package:flutter/material.dart';
import 'package:mimir/credentials/entity/credential.dart';
import 'package:mimir/credentials/i18n.dart';
import 'package:mimir/design/adaptive/editor.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/login/utils.dart';
import 'package:rettulf/rettulf.dart';

import "../i18n.dart";

enum _State {
  notStart,
  loggingIn,
  success,
}

class LoginTestTile extends StatefulWidget {
  final Credential credential;
  final Future<void> Function() login;

  const LoginTestTile({
    super.key,
    required this.credential,
    required this.login,
  });

  @override
  State<LoginTestTile> createState() => _LoginTestTileState();
}

class _LoginTestTileState extends State<LoginTestTile> {
  var loggingState = _State.notStart;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: loggingState != _State.loggingIn,
      title: i18n.loginTest.text(),
      subtitle: i18n.loginTestDesc.text(),
      leading: const Icon(Icons.login),
      trailing: Padding(
        padding: const EdgeInsets.all(8),
        child: switch (loggingState) {
          _State.loggingIn => const CircularProgressIndicator.adaptive(),
          _State.success => Icon(context.icons.checkMark, color: Colors.green),
          _ => null,
        },
      ),
      onTap: loggingState == _State.loggingIn
          ? null
          : () async {
              setState(() => loggingState = _State.loggingIn);
              try {
                await widget.login();
                if (!mounted) return;
                setState(() => loggingState = _State.success);
              } on Exception catch (error, stackTrace) {
                setState(() => loggingState = _State.notStart);
                if (!context.mounted) return;
                await handleLoginException(context: context, error: error, stackTrace: stackTrace);
              }
            },
    );
  }
}

class _I18n with CredentialsI18nMixin {
  const _I18n();
}

const _i = _I18n();

class PasswordDisplayTile extends StatefulWidget {
  final String password;
  final ValueChanged<String> onChanged;

  const PasswordDisplayTile({
    super.key,
    required this.password,
    required this.onChanged,
  });

  @override
  State<PasswordDisplayTile> createState() => _PasswordDisplayTileState();
}

class _PasswordDisplayTileState extends State<PasswordDisplayTile> {
  var showPassword = false;

  @override
  Widget build(BuildContext context) {
    final password = widget.password;
    return AnimatedSize(
      duration: const Duration(milliseconds: 100),
      child: ListTile(
        title: _i.savedPwd.text(),
        subtitle: Text(!showPassword ? _i.savedPwdDesc : password),
        leading: const Icon(Icons.password_rounded),
        trailing: [
          IconButton.filledTonal(
            icon: Icon(context.icons.edit),
            onPressed: () async {
              final newPwd = await Editor.showStringEditor(
                context,
                desc: _i.savedPwd,
                initial: "",
                secure: true,
              );
              if (newPwd == null || newPwd == password || newPwd.isEmpty) return;
              widget.onChanged(newPwd);
            },
          ),
          IconButton.filledTonal(
            onPressed: () {
              setState(() {
                showPassword = !showPassword;
              });
            },
            icon: showPassword ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
          ),
        ].wrap(spacing: 4),
      ),
    );
  }
}
