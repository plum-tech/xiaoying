import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/school/oa_announce/index.dart';
import 'package:mimir/school/ywb/index.dart';
import 'package:rettulf/rettulf.dart';
import 'i18n.dart';

class SchoolPage extends ConsumerStatefulWidget {
  const SchoolPage({super.key});

  @override
  ConsumerState<SchoolPage> createState() => _SchoolPageState();
}

class _SchoolPageState extends ConsumerState<SchoolPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                floating: true,
                snap: true,
                title: i18n.navigation.text(),
                forceElevated: innerBoxIsScrolled,
                actions: [
                  IconButton(
                    onPressed: () => context.push("/settings"),
                    icon: Icon(context.icons.settings),
                  ),
                ],
              ),
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverList.list(children: const [
              OaAnnounceAppCard(),
              YwbAppCard(),
            ]),
          ],
        ),
      ),
    );
  }
}
