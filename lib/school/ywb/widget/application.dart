import 'package:flutter/material.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/widget/expansion_tile.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/application.dart';

class YwbApplicationTile extends StatelessWidget {
  final YwbApplication application;

  const YwbApplicationTile(
    this.application, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedExpansionTile(
      title: "${application.name} #${application.workId}".text(),
      subtitle: context.formatYmdWeekText(application.startTs).text(),
      children: application.track.map((e) => YwbApplicationTrackTile(e)).toList(),
    );
  }
}

class YwbApplicationTrackTile extends StatelessWidget {
  final YwbApplicationTrack track;

  const YwbApplicationTrackTile(
    this.track, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      leading: track.isActionOk
          ? Icon(context.icons.checkMark, color: Colors.green)
          : Icon(context.icons.error, color: Colors.redAccent),
      title: track.step.text(),
      subtitle: [
        context.formatYmdhmNum(track.timestamp).text(),
        if (track.message.isNotEmpty) track.message.text(),
        track.action.text(),
      ].column(caa: CrossAxisAlignment.start),
      trailing: track.senderName.text(),
    );
  }
}

// final String resultUrl =
//     'https://ywb.sit.edu.cn/unifri-flow/WF/mobile/index.html?ismobile=1&FK_Flow=${msg.functionId}&WorkID=${msg.workId}&IsReadonly=1&IsView=1';
// Navigator.of(context)
//     .push(MaterialPageRoute(builder: (_) => YwbInAppViewPage(title: msg.name, url: resultUrl)));
