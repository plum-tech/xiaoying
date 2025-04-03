import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/widget/app.dart';
import 'package:rettulf/rettulf.dart';

import "i18n.dart";

class ExamResultUgAppCard extends ConsumerStatefulWidget {
  const ExamResultUgAppCard({super.key});

  @override
  ConsumerState<ExamResultUgAppCard> createState() => _ExamResultUgAppCardState();
}

class _ExamResultUgAppCardState extends ConsumerState<ExamResultUgAppCard> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: i18n.title.text(),
      leftActions: [
        FilledButton.icon(
          onPressed: () async {
            await context.push("/exam/result/ug");
          },
          icon: const Icon(Icons.fact_check),
          label: i18n.check.text(),
        ),
      ],
    );
  }
}
