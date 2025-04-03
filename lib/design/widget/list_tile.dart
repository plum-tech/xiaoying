import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/l10n/common.dart';

class DetailListTile extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool copyable;
  final bool enabled;
  final VoidCallback? onTap;

  const DetailListTile({
    super.key,
    this.title,
    this.subtitle,
    this.copyable = true,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return ListTile(
      leading: leading,
      trailing: trailing,
      title: title?.text(),
      subtitle: subtitle?.text(),
      visualDensity: VisualDensity.compact,
      enabled: enabled,
      onTap: onTap,
      onLongPress: copyable && subtitle != null
          ? () async {
              final title = this.title;
              if (title != null) {
                context.showSnackBar(content: const CommonI18n().copyTipOf(title).text());
              }
              await Clipboard.setData(ClipboardData(text: subtitle));
            }
          : null,
    );
  }
}
