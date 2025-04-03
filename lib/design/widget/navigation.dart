import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';

class PageNavigationTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final String path;

  const PageNavigationTile({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Icon(context.icons.rightChevron),
      onTap: () {
        context.push(path);
      },
    );
  }
}
