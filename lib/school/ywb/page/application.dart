import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mimir/design/animation/progress.dart';
import 'package:mimir/design/widget/common.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/utils/error.dart';

import '../entity/application.dart';
import '../init.dart';
import '../widget/application.dart';
import '../i18n.dart';

class YwbMyApplicationListPage extends StatefulWidget {
  const YwbMyApplicationListPage({super.key});

  @override
  State<YwbMyApplicationListPage> createState() => _YwbMyApplicationListPageState();
}

class _YwbMyApplicationListPageState extends State<YwbMyApplicationListPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: YwbApplicationType.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: i18n.mine.title.text(),
          bottom: TabBar(
            isScrollable: true,
            tabs: YwbApplicationType.values
                .map((type) => Tab(
                      child: type.l10nName().text(),
                    ))
                .toList(),
          ),
        ),
        body: TabBarView(
          // These are the contents of the tab views, below the tabs.
          children: YwbApplicationType.values.mapIndexed((i, type) {
            return YwbApplicationLoadingList(type: type);
          }).toList(),
        ),
      ),
    );
  }
}

class YwbApplicationLoadingList extends StatefulWidget {
  final YwbApplicationType type;

  const YwbApplicationLoadingList({
    super.key,
    required this.type,
  });

  @override
  State<YwbApplicationLoadingList> createState() => _YwbApplicationLoadingListState();
}

class _YwbApplicationLoadingListState extends State<YwbApplicationLoadingList> with AutomaticKeepAliveClientMixin {
  bool fetching = false;
  late var applications = YwbInit.applicationStorage.getApplicationListOf(widget.type);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) async {
      await fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final applications = this.applications;
    return applications == null
        ? const SizedBox()
        : WhenLoading(
            loading: fetching,
            child: buildList(applications),
          );
  }

  Widget buildList(List<YwbApplication> applications) {
    return applications.isEmpty
        ? LeavingBlank(
            icon: Icons.inbox_outlined,
            desc: i18n.mine.noApplicationsTip,
          )
        : ListView.builder(
            itemCount: applications.length,
            itemBuilder: (ctx, index) {
              return Card.filled(
                clipBehavior: Clip.hardEdge,
                child: YwbApplicationTile(applications[index]),
              );
            },
          );
  }

  Future<void> fetch() async {
    if (fetching) return;
    if (!mounted) return;
    setState(() {
      fetching = true;
    });
    final type = widget.type;
    try {
      final applications = await YwbInit.applicationService.getApplicationsOf(type);
      await YwbInit.applicationStorage.setApplicationListOf(type, applications);
      if (!mounted) return;
      setState(() {
        this.applications = applications;
        fetching = false;
      });
    } catch (error, stackTrace) {
      handleRequestError(error, stackTrace);
      if (!mounted) return;
      setState(() {
        fetching = false;
      });
    }
  }
}
