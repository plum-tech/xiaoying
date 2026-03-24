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
            title: "设置".text(),
          ),
          SliverList.list(children: buildEntries()),
        ],
      ),
    );
  }

  List<Widget> buildEntries() {
    final all = <Widget>[];
    final agreementAccepted =
        ref.watch(
          Settings.agreements.$basicAcceptanceOf(AgreementVersion.current),
        ) ??
        false;
    if (agreementAccepted) {
      all.add(
        PageNavigationTile(
          leading: const Icon(Icons.calendar_month_outlined),
          title: "课程表".text(),
          path: "/settings/timetable",
        ),
      );
      all.add(const Divider());
    }
    if (agreementAccepted) {
      all.add(const ClearCacheTile());
      all.add(const WipeDataTile());
    }
    all.add(
      PageNavigationTile(
        title: "关于".text(),
        leading: Icon(context.icons.info),
        path: "/settings/about",
      ),
    );
    all[all.length - 1] = all.last.safeArea(t: false);
    return all;
  }
}

class ClearCacheTile extends StatelessWidget {
  const ClearCacheTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: "清空缓存".text(),
      subtitle: "清空使用过程中产生的离线缓存和 Cookies".text(),
      leading: const Icon(Icons.folder_delete_outlined),
      onTap: () {
        _onClearCache(context);
      },
    );
  }
}

void _onClearCache(BuildContext context) async {
  final confirm = await context.showActionRequest(
    action: "清空缓存",
    desc: "清空缓存后，相关离线数据需要重新生成。",
    cancel: "取消",
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
      title: "擦除数据".text(),
      subtitle: "擦除所有本地数据".text(),
      leading: const Icon(Icons.delete_forever_rounded),
      onTap: _onWipeData,
    );
  }
}

Future<void> _onWipeData() async {
  final navigateCtx = $key.currentContext;
  if (navigateCtx == null || !navigateCtx.mounted) return;
  final confirm = await navigateCtx.showActionRequest(
    action: "擦除所有数据",
    desc: "此操作将永久擦除你的缓存和其他本地信息，如已导入的课程表。",
    cancel: "取消",
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
