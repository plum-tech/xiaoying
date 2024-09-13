import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/design/widgets/list_tile.dart';
import 'package:mimir/r.dart';
import 'package:mimir/settings/dev.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/backend/update/utils.dart';
import 'package:mimir/utils/error.dart';
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
    final devMode = ref.watch(Dev.$on);
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
              if (devMode)
                DetailListTile(
                  title: "Installer Store",
                  subtitle: R.meta.installerStore ?? i18n.unknown,
                ),
              DetailListTile(
                title: i18n.about.icpLicense,
                subtitle: R.icpLicense,
                trailing: const Icon(Icons.open_in_browser),
                onTap: () async {
                  await guardLaunchUrlString(context, "https://beian.miit.gov.cn/");
                },
              ),
              ListTile(
                title: i18n.about.termsOfService.text(),
                trailing: const Icon(Icons.open_in_browser),
                onTap: () async {
                  await guardLaunchUrlString(context, "https://www.mysit.life/tos");
                },
              ),
              ListTile(
                title: i18n.about.privacyPolicy.text(),
                trailing: const Icon(Icons.open_in_browser),
                onTap: () async {
                  await guardLaunchUrlString(context, "https://www.mysit.life/privacy-policy");
                },
              ),
              ListTile(
                title: i18n.about.marketingWebsite.text(),
                trailing: const Icon(Icons.open_in_browser),
                onTap: () async {
                  await guardLaunchUrlString(context, "https://www.mysit.life");
                },
              ),
              AboutListTile(
                // FIXME: icon is buggy
                // icon: SvgPicture.asset("assets/icon.svg").sizedAll(32),
                applicationName: R.appNameL10n,
                applicationVersion: R.meta.version.toString(),
                applicationLegalese: "Copyright©️2024 Plum Technology Ltd. All Rights Reserved.",
              ),
              if (devMode)
                DetailListTile(
                  title: "UUID",
                  subtitle: R.uuid,
                )
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
    final devOn = ref.watch(Dev.$on);
    final version = R.meta;
    return ListTile(
      leading: Icon(getDeviceIcon(R.meta, R.deviceInfo)),
      title: i18n.about.version.text(),
      subtitle: "${version.platform.name} ${version.version.toString()}".text(),
      trailing: kIsWeb ? null : const CheckUpdateButton(),
      onTap: devOn && clickCount <= 10
          ? null
          : () async {
              if (ref.read(Dev.$on)) return;
              clickCount++;
              if (clickCount >= 10) {
                clickCount = 0;
                context.showSnackBar(content: i18n.dev.devModeActivateTip.text());
                await ref.read(Dev.$on.notifier).set(true);
                await HapticFeedback.mediumImpact();
              }
            },
    );
  }
}

class CheckUpdateButton extends StatefulWidget {
  const CheckUpdateButton({super.key});

  @override
  State<CheckUpdateButton> createState() => _CheckUpdateButtonState();
}

class _CheckUpdateButtonState extends State<CheckUpdateButton> {
  var isChecking = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: isChecking
          ? null
          : () async {
              setState(() {
                isChecking = true;
              });
              try {
                await checkAppUpdate(context: context, manually: true);
              } catch (error, stackTrace) {
                debugPrintError(error, stackTrace);
              }
              setState(() {
                isChecking = false;
              });
            },
      child: i18n.about.checkUpdate.text(),
    );
  }
}
