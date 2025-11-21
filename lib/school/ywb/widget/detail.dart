import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mimir/session/ywb.dart';
import 'package:mimir/widget/html.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/service.dart';

class YwbApplicationDetailSectionBlock extends StatelessWidget {
  final YwbServiceDetailSection section;

  const YwbApplicationDetailSectionBlock(this.section, {super.key});

  @override
  Widget build(BuildContext context) {
    final bodyWidget = switch (section.type) {
      'html' => buildHtmlSection(section.content),
      'json' => buildJsonSection(section.content),
      _ => const SizedBox.shrink(),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.section, style: context.textTheme.headlineSmall),
          bodyWidget,
        ],
      ),
    );
  }

  Widget buildJsonSection(String content) {
    final Map pairs = jsonDecode(content);
    return pairs.entries.map((e) => '${e.key}: ${e.value}'.text()).toList().column();
  }

  Widget buildHtmlSection(String content) {
    // TODO: cannot download pdf files
    final html = content.replaceAll('../app/files/', '${YwbSession.base}/app/files/');
    return RestyledHtmlWidget(
      html,
      async: false,
    );
  }
}
