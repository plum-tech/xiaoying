import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/widget/markdown.dart';
import 'package:rettulf/rettulf.dart';
import '../entity/agreements.dart';

class AgreementsAcceptanceSheet extends ConsumerStatefulWidget {
  const AgreementsAcceptanceSheet({super.key});

  @override
  ConsumerState createState() => _AgreementsAcceptanceSheetState();

  static Future<bool> show(BuildContext context) async {
    if (_sheetCount < 1) {
      final res = await showModalBottomSheet(
        context: context,
        builder: (_) => const AgreementsAcceptanceSheet(),
        isDismissible: false,
        enableDrag: false,
        useRootNavigator: true,
        useSafeArea: true,
      );
      return res == true;
    }
    return Settings.agreements.getBasicAcceptanceOf(AgreementVersion.current) ??
        false;
  }
}

var _sheetCount = 0;

class _AgreementsAcceptanceSheetState
    extends ConsumerState<AgreementsAcceptanceSheet> {
  @override
  void initState() {
    super.initState();
    _sheetCount++;
  }

  @override
  void dispose() {
    super.dispose();
    _sheetCount--;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: "隐私政策".text(),
        actions: [
          PlatformIconButton(
            onPressed: () {
              context.push("/settings");
            },
            icon: Icon(context.icons.settings),
          ),
        ],
      ),
      body: const FeaturedMarkdownWidget(
        data: """
小应生活在提供服务时需要收集您的相关信息及以下权限：

访问网络以获取您在学校各系统中的信息；使用摄像头以扫描二维码；读写相册以从照片中扫描二维码和保存生成的图片；读写日历以添加考试提醒和课程表；读取外部存储空间以导入您所选的课程表文件；写入外部存储空间以将您导出的课程表文件保存至本地文件系统。

当您在使用具体功能时，我们需要获取您与该功能相应所需的权限。
未经您的许可，我们不会向第三方披露、共享或提供您的个人信息。
您可以根据我们的指引、访问、更正、删除您的信息或撤销您的相关授权。您可以通过查看《小应生活隐私政策》中的联系方式来与我们联系。

更多详情请阅读完整版的 [《小应生活隐私政策》](https://www.xiaoying.life/privacy-policy) 和 [《小应生活使用协议》](https://www.xiaoying.life/terms-of-service)。
""",
      ).scrolled().padSymmetric(h: 15),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child:
            [
              OutlinedButton(
                child: "拒绝".text(),
                onPressed: () async {
                  await context.showTip(
                    desc: "只有接受我们的隐私政策后，您才可享用小应生活的功能",
                    primary: "好的",
                  );
                },
              ).expanded(),
              const SizedBox(width: 15),
              FilledButton(
                child: "同意并继续".text(),
                onPressed: () {
                  Settings.agreements.setBasicAcceptanceOf(
                    AgreementVersion.current,
                    true,
                  );
                  context.pop(true);
                },
              ).expanded(),
            ].row(
              maa: MainAxisAlignment.spaceEvenly,
              caa: CrossAxisAlignment.center,
            ),
      ),
    );
  }
}
