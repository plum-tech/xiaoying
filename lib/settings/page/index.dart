import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/agreements/entity/agreements.dart';
import 'package:mimir/agreements/page/privacy_policy.dart';
import 'package:mimir/credentials/entity/login_status.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/lifecycle.dart';
import 'package:mimir/login/i18n.dart';
import 'package:mimir/storage/hive/init.dart';
import 'package:mimir/init.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/school/widget/campus.dart';
import 'package:rettulf/rettulf.dart';

import '../i18n.dart';
import '../../design/widget/navigation.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
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
            title: i18n.title.text(),
          ),
          SliverList.list(
            children: buildEntries(),
          ),
        ],
      ),
    );
  }

  List<Widget> buildEntries() {
    final all = <Widget>[];
    final agreementAccepted = ref.watch(Settings.agreements.$basicAcceptanceOf(AgreementVersion.current)) ?? false;
    if (agreementAccepted) {
      final oaLoginStatus = ref.watch(CredentialsInit.storage.oa.$loginStatus);
      if (oaLoginStatus != OaLoginStatus.never) {
        all.add(const CampusSelector().padSymmetric(h: 8));
      }
    }
    if (agreementAccepted) {
      final oaCredentials = ref.watch(CredentialsInit.storage.oa.$credentials);
      if (oaCredentials != null) {
        all.add(PageNavigationTile(
          title: i18n.oa.oaAccount.text(),
          subtitle: oaCredentials.account.text(),
          leading: const Icon(Icons.person_rounded),
          path: "/settings/oa",
        ));
      } else {
        const oaLogin = OaLoginI18n();
        all.add(ListTile(
          title: oaLogin.loginOa.text(),
          subtitle: oaLogin.neverLoggedInTip.text(),
          leading: const Icon(Icons.person_rounded),
          onTap: () {
            context.go("/oa/login");
          },
        ));
      }
      all.add(const Divider());
    }
    all.add(const ThemeModeTile());
    all.add(const ThemeColorTile());
    all.add(const Divider());

    if (agreementAccepted) {
      all.add(PageNavigationTile(
        leading: const Icon(Icons.calendar_month_outlined),
        title: i18n.app.navigation.timetable.text(),
        path: "/settings/timetable",
      ));
      all.add(PageNavigationTile(
        title: i18n.app.navigation.school.text(),
        leading: const Icon(Icons.school_outlined),
        path: "/settings/school",
      ));
      all.add(const Divider());
    }
    if (agreementAccepted) {
      all.add(const ClearCacheTile());
      all.add(const WipeDataTile());
    }
    all.add(PageNavigationTile(
      title: i18n.about.title.text(),
      leading: Icon(context.icons.info),
      path: "/settings/about",
    ));
    all[all.length - 1] = all.last.safeArea(t: false);
    return all;
  }
}

class ThemeColorTile extends StatelessWidget {
  const ThemeColorTile({super.key});

  @override
  Widget build(BuildContext context) {
    return PageNavigationTile(
      leading: const Icon(Icons.color_lens_outlined),
      title: i18n.themeColor.text(),
      path: "/settings/theme-color",
    );
  }
}

class ThemeModeTile extends ConsumerWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(Settings.theme.$themeMode) ?? ThemeMode.system;
    return ListTile(
      leading: switch (themeMode) {
        ThemeMode.dark => const Icon(Icons.dark_mode),
        ThemeMode.light => const Icon(Icons.light_mode),
        ThemeMode.system => const Icon(Icons.brightness_auto),
      },
      isThreeLine: true,
      title: i18n.themeModeTitle.text(),
      subtitle: ThemeMode.values
          .map((mode) => ChoiceChip(
                label: mode.l10n().text(),
                selected: Settings.theme.themeMode == mode,
                onSelected: (value) async {
                  ref.read(Settings.theme.$themeMode.notifier).set(mode);
                  await HapticFeedback.mediumImpact();
                },
              ))
          .toList()
          .wrap(spacing: 4),
    );
  }
}

class ClearCacheTile extends StatelessWidget {
  const ClearCacheTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: i18n.clearCacheTitle.text(),
      subtitle: i18n.clearCacheDesc.text(),
      leading: const Icon(Icons.folder_delete_outlined),
      onTap: () {
        _onClearCache(context);
      },
    );
  }
}

void _onClearCache(BuildContext context) async {
  final confirm = await context.showActionRequest(
    action: i18n.clearCacheTitle,
    desc: i18n.clearCacheRequest,
    cancel: i18n.cancel,
    destructive: true,
  );
  if (confirm == true) {
    await Init.schoolCookieJar.deleteAll();
    await HiveInit.clearCache();
  }
}

class WipeDataTile extends StatelessWidget {
  const WipeDataTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: i18n.wipeDataTitle.text(),
      subtitle: i18n.wipeDataDesc.text(),
      leading: const Icon(Icons.delete_forever_rounded),
      onTap: _onWipeData,
    );
  }
}

Future<void> _onWipeData() async {
  final navigateCtx = $key.currentContext;
  if (navigateCtx == null || !navigateCtx.mounted) return;
  final confirm = await navigateCtx.showActionRequest(
    action: i18n.wipeDataRequest,
    desc: i18n.wipeDataRequestDesc,
    cancel: i18n.cancel,
    destructive: true,
  );
  if (confirm == true) {
    await HiveInit.clear(); // Clear storage
    await Init.initNetwork();
    await Init.initModules();
    if (!navigateCtx.mounted) return;
    navigateCtx.go("/oa/login");
    await Future.delayed(const Duration(milliseconds: 100));
    if (!navigateCtx.mounted) return;
    await AgreementsAcceptanceSheet.show(navigateCtx);
  }
}
