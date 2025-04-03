import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

class TagsGroup extends StatelessWidget {
  final List<String> tags;

  const TagsGroup(
    this.tags, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return tags
        .map(
          (tag) => Chip(
            label: tag.text(),
            padding: EdgeInsets.zero,
            labelStyle: textTheme.bodySmall,
            elevation: 4,
          ),
        )
        .toList()
        .wrap(spacing: 4);
  }
}
