import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mimir/r.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/utils/guard_launch.dart';
import '../widget/device.dart';

class AboutSettingsPage extends ConsumerStatefulWidget {
  const AboutSettingsPage({super.key});

  @override
  ConsumerState<AboutSettingsPage> createState() => _AboutSettingsPageState();
}

class _AboutSettingsPageState extends ConsumerState<AboutSettingsPage> {
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
            title: "关于".text(),
          ),
          SliverList.list(
            children: [
              const VersionTile(),
              ListTile(
                title: "服务条款".text(),
                trailing: const Icon(Icons.open_in_browser),
                onTap: () async {
                  await guardLaunchUrlString(
                    context,
                    "https://www.xiaoying.life/terms-of-service",
                  );
                },
              ),
              ListTile(
                title: "隐私政策".text(),
                trailing: const Icon(Icons.open_in_browser),
                onTap: () async {
                  await guardLaunchUrlString(
                    context,
                    "https://www.xiaoying.life/privacy-policy",
                  );
                },
              ),
              ListTile(
                title: "官网".text(),
                trailing: const Icon(Icons.open_in_browser),
                onTap: () async {
                  await guardLaunchUrlString(
                    context,
                    "https://www.xiaoying.life",
                  );
                },
              ),
              AboutListTile(
                icon: SvgPicture.asset("assets/icon.svg").sizedAll(32),
                applicationName: R.appName,
                applicationVersion: R.meta.version.toString(),
                applicationLegalese:
                    "Copyright©️2023-2026 Plum Technology Ltd. All Rights Reserved.",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VersionTile extends ConsumerStatefulWidget {
  const VersionTile({super.key});

  @override
  ConsumerState<VersionTile> createState() => _VersionTileState();
}

class _VersionTileState extends ConsumerState<VersionTile> {
  int clickCount = 0;

  @override
  Widget build(BuildContext context) {
    final version = R.meta;
    return ListTile(
      leading: Icon(getDeviceIcon(R.meta, R.deviceInfo)),
      title: "版本".text(),
      subtitle: "${version.platform.name} ${version.version.toString()}".text(),
    );
  }
}
