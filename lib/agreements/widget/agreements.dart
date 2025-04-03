import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/widget/markdown.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/agreements.dart';
import '../i18n.dart';

class AgreementsCheckBox extends ConsumerWidget {
  final AgreementType type;

  const AgreementsCheckBox({
    super.key,
    required this.type,
  });

  const AgreementsCheckBox.basic({
    super.key,
  }) : type = AgreementType.basic;

  const AgreementsCheckBox.account({
    super.key,
  }) : type = AgreementType.account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreements = Settings.agreements;
    final acceptance = switch (type) {
      AgreementType.basic => agreements.$basicAcceptanceOf,
      AgreementType.account => agreements.$accountAcceptanceOf,
    };
    final $accepted = acceptance(AgreementVersion.current);
    final accepted = ref.watch($accepted) ?? false;
    return [
      Checkbox.adaptive(
        value: accepted,
        onChanged: (newV) {
          ref.read($accepted.notifier).set(newV);
        },
      ),
      FeaturedMarkdownWidget(data: type.l10n()).expanded(flex: 9),
    ].row();
  }
}

Future<void> showAgreementsRequired2Accept(BuildContext context) async {
  await context.showTip(
    title: i18n.acceptanceRequired,
    desc: i18n.acceptanceRequiredDesc,
    primary: i18n.ok,
  );
}
