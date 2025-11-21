import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mimir/design/widget/list_tile.dart';
import 'package:mimir/design/widget/tags.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/widget/html.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/utils/error.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../entity/announce.dart';
import '../init.dart';
import '../i18n.dart';
import '../service/announce.dart';
import '../widget/attachment.dart';

class AnnounceDetailsPage extends StatefulWidget {
  final OaAnnounceRecord record;

  const AnnounceDetailsPage(
    this.record, {
    super.key,
  });

  @override
  State<AnnounceDetailsPage> createState() => _AnnounceDetailsPageState();
}

class _AnnounceDetailsPageState extends State<AnnounceDetailsPage> {
  late OaAnnounceDetails? details = OaAnnounceInit.storage.getAnnounceDetails(widget.record.uuid);
  bool fetching = false;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    if (details != null) return;
    if (!mounted) return;
    setState(() {
      fetching = true;
    });
    try {
      final catalogId = widget.record.catalogId;
      final uuid = widget.record.uuid;
      final details = await OaAnnounceInit.service.fetchAnnounceDetails(catalogId, uuid);
      OaAnnounceInit.storage.setAnnounceDetails(uuid, details);
      if (!mounted) return;
      setState(() {
        this.details = details;
        fetching = false;
      });
    } catch (error, stackTrace) {
      handleRequestError(error, stackTrace);
      if (!mounted) return;
      setState(() {
        fetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = this.details;
    final record = widget.record;
    return Scaffold(
      body: SelectionArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: i18n.title.text(),
              actions: [
                PlatformIconButton(
                  onPressed: () {
                    launchUrlString(
                      OaAnnounceService.getAnnounceUrl(widget.record.catalogId, widget.record.uuid),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  icon: const Icon(Icons.open_in_browser),
                ),
              ],
            ),
            buildInfo(),
            if (details != null && details.attachments.isNotEmpty)
              SliverList.list(children: [
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: i18n.info.attachmentHeader(details.attachments.length).text(),
                )
              ]),
            if (details != null)
              SliverList.builder(
                itemCount: details.attachments.length,
                itemBuilder: (ctx, i) => AttachmentLinkTile(
                  details.attachments[i],
                  uuid: record.uuid,
                ),
              ),
            if (details != null) ...[
              const Divider().sliver(),
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: RestyledHtmlWidget(
                  details.content,
                  linkifyPhoneNumbers: true,
                  renderMode: RenderMode.sliverList,
                ),
              ),
            ]
          ],
        ),
      ),
      floatingActionButton: !fetching ? null : const CircularProgressIndicator.adaptive(),
    );
  }

  Widget buildInfo() {
    final details = this.details;
    final record = widget.record;
    final (:title, :tags) = separateTagsFromTitle(record.title);
    return SliverList.list(children: [
      DetailListTile(
        title: i18n.info.title,
        subtitle: title,
      ),
      if (details != null)
        DetailListTile(
          title: i18n.info.author,
          subtitle: details.author,
        ),
      DetailListTile(
        title: i18n.info.publishTime,
        subtitle: context.formatYmdText(record.dateTime),
      ),
      DetailListTile(
        title: i18n.info.department,
        subtitle: record.departments.join(", "),
      ),
      if (tags.isNotEmpty)
        ListTile(
          isThreeLine: true,
          title: i18n.info.tags.text(),
          subtitle: TagsGroup(tags),
        )
    ]);
  }
}
