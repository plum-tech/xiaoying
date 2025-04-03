import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/widget/app.dart';
import 'package:rettulf/rettulf.dart';

import "i18n.dart";

class ExamResultPgAppCard extends ConsumerStatefulWidget {
  const ExamResultPgAppCard({super.key});

  @override
  ConsumerState<ExamResultPgAppCard> createState() => _ExamResultPgAppCardState();
}

class _ExamResultPgAppCardState extends ConsumerState<ExamResultPgAppCard> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: i18n.title.text(),
      leftActions: [
        FilledButton.icon(
          onPressed: () async {
            await context.push("/exam/result/pg");
          },
          icon: const Icon(Icons.fact_check),
          label: i18n.check.text(),
        ),
      ],
    );
  }
}
