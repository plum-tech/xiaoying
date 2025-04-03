import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/credentials/entity/credential.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/init.dart';
import '../i18n.dart';
import '../widget/credentials.dart';

const _changePasswordUrl = "https://authserver.sit.edu.cn/authserver/passwordChange.do";

class OaSettingsPage extends ConsumerStatefulWidget {
  const OaSettingsPage({super.key});

  @override
  ConsumerState<OaSettingsPage> createState() => _OaSettingsPageState();
}

class _OaSettingsPageState extends ConsumerState<OaSettingsPage> {
  var showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar.large(
            pinned: true,
            snap: false,
            floating: false,
            title: i18n.oa.oaAccount.text(),
          ),
          buildBody(),
        ],
      ),
    );
  }

  Widget buildBody() {
    final credential = ref.watch(CredentialsInit.storage.oa.$credentials);
    final all = <WidgetBuilder>[];
    if (credential != null) {
      all.add((_) => buildAccount(credential));
      all.add((_) => const Divider());
      all.add(
        (_) => PasswordDisplayTile(
          password: credential.password,
          onChanged: (pwd) {
            CredentialsInit.storage.oa.credentials = credential.copyWith(password: pwd);
          },
        ),
      );
      all.add(
        (_) => LoginTestTile(
          credential: credential,
          login: () async {
            await Init.ssoSession.deleteSitUriCookies();
            await Init.ssoSession.loginLocked(credential, active: true);
          },
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: all.length,
        (ctx, index) {
          return all[index](ctx);
        },
      ),
    );
  }

  Widget buildAccount(Credential credential) {
    return ListTile(
      title: i18n.oa.oaAccount.text(),
      subtitle: credential.account.text(),
      leading: Icon(context.icons.person),
      trailing: Icon(context.icons.copy),
      onTap: () async {
        context.showSnackBar(content: i18n.copyTipOf(i18n.oa.oaAccount).text());
        // Copy the student ID to clipboard
        await Clipboard.setData(ClipboardData(text: credential.account));
      },
    );
  }
}
