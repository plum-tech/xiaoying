import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mimir/r.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/utils/guard_launch.dart';
import '../i18n.dart';
import '../widget/device.dart';

class AboutSettingsPage extends ConsumerStatefulWidget {
  const AboutSettingsPage({
    super.key,
  });

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
            title: i18n.about.title.text(),
          ),
          SliverList.list(
            children: [
              const VersionTile(),
              ListTile(
                title: i18n.about.termsOfService.text(),
                trailing: const Icon(Icons.open_in_browser),
                onTap: () async {
                  await guardLaunchUrlString(context, "https://www.xiaoying.life/tos");
                },
              ),
              ListTile(
                title: i18n.about.privacyPolicy.text(),
                trailing: const Icon(Icons.open_in_browser),
                onTap: () async {
                  await guardLaunchUrlString(context, "https://www.xiaoying.life/privacy-policy");
                },
              ),
              ListTile(
                title: i18n.about.marketingWebsite.text(),
                trailing: const Icon(Icons.open_in_browser),
                onTap: () async {
                  await guardLaunchUrlString(context, "https://www.xiaoying.life");
                },
              ),
              AboutListTile(
                icon: SvgPicture.asset("assets/icon.svg").sizedAll(32),
                applicationName: R.appNameL10n,
                applicationVersion: R.meta.version.toString(),
                applicationLegalese: "Copyright©️2024-2025 Plum Technology Ltd. All Rights Reserved.",
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
      title: i18n.about.version.text(),
      subtitle: "${version.platform.name} ${version.version.toString()}".text(),
    );
  }
}
