import 'package:flutter/material.dart';
import 'package:mimir/mini_apps/activity/entity/list.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/detail.dart';
import '../init.dart';
import '../widgets/background.dart';
import '../using.dart';

String _getActivityUrl(int activityId) {
  return 'http://sc.sit.edu.cn/public/activity/activityDetail.action?activityId=$activityId';
}

class DetailPage extends StatefulWidget {
  final Activity activity;
  final Object hero;
  final bool enableApply;

  const DetailPage(this.activity, {required this.hero, this.enableApply = true, super.key});

  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with AutomaticKeepAliveClientMixin {
  int get activityId => widget.activity.id;

  Activity get activity => widget.activity;
  ActivityDetail? detail;
  Size? titleBarSize;

  @override
  void initState() {
    super.initState();
    ScInit.scActivityDetailService.getActivityDetail(activityId).then((value) {
      setState(() {
        detail = value;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleBarSize = _fabKey.currentContext?.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return context.isPortrait ? buildPortrait(context) : buildLandscape(context);
  }

  Widget buildPortrait(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: i18n.details.text(),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () {
              launchUrlInBrowser(_getActivityUrl(activityId));
            },
          )
        ],
      ),
      body: buildDetailPortrait(ctx, detail),
      floatingActionButton: widget.enableApply
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.person_add),
              label: i18n.apply.btn.text(),
              onPressed: () async {
                await showApplyRequest(ctx);
              },
            )
          : null,
    );
  }

  final _fabKey = GlobalKey(debugLabel: "To get size of FAB in Landscape Mode.");

  Widget buildLandscape(BuildContext ctx) {
    if (ctx.adaptive.isSubpage) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: titleBarSize?.height,
            actions: [
              if (widget.enableApply)
                PlainExtendedButton(
                    label: i18n.apply.btn.text(),
                    icon: const Icon(Icons.person_add),
                    tap: () async {
                      await showApplyRequest(ctx);
                    }),
              PlainExtendedButton(
                  key: _fabKey,
                  label: i18n.open.text(),
                  icon: const Icon(Icons.open_in_browser),
                  tap: () {
                    launchUrlInBrowser(_getActivityUrl(activityId));
                  }),
            ],
          ),
          body: buildDetailLandscape(ctx, detail));
    } else {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: i18n.details.text(),
          actions: [
            if (widget.enableApply)
              PlainExtendedButton(
                  label: i18n.apply.btn.text(),
                  icon: const Icon(Icons.person_add),
                  tap: () async {
                    await showApplyRequest(ctx);
                  }),
            PlainExtendedButton(
                label: i18n.open.text(),
                icon: const Icon(Icons.open_in_browser),
                tap: () {
                  launchUrlInBrowser(_getActivityUrl(activityId));
                })
          ],
        ),
        body: buildDetailLandscape(ctx, detail),
      );
    }
  }

  Widget buildInfoCardPortrait(BuildContext ctx, ActivityDetail? detail) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.8,
          child: ColorfulCircleBackground(seed: detail?.id),
        ),
        buildGlassmorphismBg(ctx),
        buildActivityInfo(ctx, detail).padAll(8).inCard().hero(widget.hero).padAll(20),
      ],
    );
  }

  Widget buildInfoCardLandscape(BuildContext context, ActivityDetail? detail) {
    return buildActivityInfo(context, detail)
        .padAll(8)
        .scrolled(physics: const ClampingScrollPhysics())
        .inCard()
        .padAll(10);
  }

  Widget _buildArticle(BuildContext context, String? html) {
    if (html == null) {
      return i18n.detailEmptyTip.text(style: context.textTheme.titleLarge).center();
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: MyHtmlWidget(
        html,
        isSelectable: true,
        textStyle: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget buildDetailPortrait(BuildContext ctx, ActivityDetail? detail) {
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        buildInfoCardPortrait(context, detail),
        if (detail != null) _buildArticle(context, detail.description) else const LoadingPlaceholder.drop(),
        const SizedBox(height: 64),
      ]),
    );
  }

  Widget buildDetailLandscape(BuildContext ctx, ActivityDetail? detail) {
    return [
      ColorfulCircleBackground(seed: detail?.id).padAll(20),
      ClipRRect(
        child: buildGlassmorphismBg(ctx),
      ),
      Row(mainAxisSize: MainAxisSize.min, children: [
        buildInfoCardLandscape(context, detail).align(at: Alignment.topCenter).expanded(),
        if (detail != null)
          _buildArticle(context, detail.description).align(at: Alignment.topCenter).expanded()
        else
          const LoadingPlaceholder.drop().expanded(),
      ])
    ].stack();
  }

  Future<void> showApplyRequest(BuildContext ctx) async {
    final confirm = await ctx.showRequest(
        title: i18n.apply.applyRequest,
        desc: i18n.apply.applyRequestDesc,
        yes: i18n.confirm,
        no: i18n.notNow,
        highlight: true);
    if (confirm == true) {
      try {
        final response = await ScInit.scJoinActivityService.join(activityId);
        if (!mounted) return;
        await ctx.showTip(title: i18n.apply.replyTip, desc: response, ok: i18n.ok);
      } catch (e) {
        if (!mounted) return;
        await ctx.showTip(
          title: i18n.error,
          desc: e.toString(),
          ok: i18n.ok,
          serious: true,
        );
        rethrow;
      }
    }
  }

  Future<void> _sendRequest(BuildContext context, bool force) async {
    try {
      final response = await ScInit.scJoinActivityService.join(activityId, force);
      if (!mounted) return;
      context.showSnackBar(Text(response));
    } catch (e) {
      context.showSnackBar(Text('错误: ${e.runtimeType}'), duration: const Duration(seconds: 3));
      rethrow;
    }
  }

  Widget buildActivityInfo(BuildContext context, ActivityDetail? detail) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall;
    final valueStyle = Theme.of(context).textTheme.bodyMedium;
    final keyStyle = valueStyle?.copyWith(fontWeight: FontWeight.bold);

    buildRow(String key, Object? value) => TableRow(
          children: [
            Text(key, style: keyStyle),
            Text(value?.toString() ?? "...", style: valueStyle),
          ],
        );

    return Column(
      children: [
        Text(activity.realTitle, style: titleStyle, softWrap: true).padAll(10),
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          },
          children: [
            buildRow(i18n.id, activity.id),
            buildRow(i18n.location, detail?.place),
            buildRow(i18n.principal, detail?.principal),
            buildRow(i18n.organizer, detail?.organizer),
            buildRow(i18n.undertaker, detail?.undertaker),
            buildRow(i18n.contactInfo, detail?.contactInfo),
            buildRow(i18n.startTime, detail?.startTime),
            buildRow(i18n.duration, detail?.duration),
            buildRow(i18n.tags, activity.tags.join(' ')),
          ],
        ).padH(10),
      ],
    ).scrolled(physics: const NeverScrollableScrollPhysics()).padAll(10);
  }

  @override
  bool get wantKeepAlive => true;
}
