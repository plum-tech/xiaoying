import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/widget/tags.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:mimir/school/utils.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/announce.dart';

class OaAnnounceTile extends StatelessWidget {
  final OaAnnounceRecord record;

  const OaAnnounceTile(
    this.record, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final (:title, :tags) = separateTagsFromTitle(record.title);

    return ListTile(
      isThreeLine: true,
      titleTextStyle: textTheme.titleMedium,
      title: title.text(),
      subtitleTextStyle: textTheme.bodySmall,
      subtitle: TagsGroup(record.departments + tags),
      trailing: context.formatYmdNum(record.dateTime).text(style: textTheme.bodySmall),
      onTap: () {
        context.push("/oa/announcement/details", extra: record);
      },
    );
  }
}
