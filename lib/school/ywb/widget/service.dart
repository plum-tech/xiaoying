import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/service.dart';

class YwbServiceTile extends StatelessWidget {
  final YwbService meta;
  final bool isHot;

  const YwbServiceTile({super.key, required this.meta, required this.isHot});

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyMedium;
    final views = isHot
        ? [
            Text(meta.count.toString(), style: style),
            const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.red,
            ),
          ].row(mas: MainAxisSize.min)
        : Text(meta.count.toString(), style: style);

    return ListTile(
      title: Text(
        meta.name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        meta.summary,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: views,
      onTap: () {
        context.push("/ywb/details", extra: meta);
      },
    );
  }
}
