import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/agreements/entity/agreements.dart';
import 'package:mimir/agreements/page/privacy_policy.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/lifecycle.dart';
import 'package:mimir/storage/hive/init.dart';
import 'package:mimir/init.dart';
import 'package:mimir/settings/settings.dart';
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
      all.add(PageNavigationTile(
        leading: const Icon(Icons.calendar_month_outlined),
        title: i18n.app.navigation.timetable.text(),
        path: "/settings/timetable",
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
    navigateCtx.go("/");
    await Future.delayed(const Duration(milliseconds: 100));
    if (!navigateCtx.mounted) return;
    await AgreementsAcceptanceSheet.show(navigateCtx);
  }
}
