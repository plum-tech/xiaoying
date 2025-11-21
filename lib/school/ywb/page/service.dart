import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/widget/common.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/utils/error.dart';

import '../entity/service.dart';
import '../init.dart';
import '../widget/service.dart';
import '../i18n.dart';

class YwbServiceListPage extends StatefulWidget {
  const YwbServiceListPage({super.key});

  @override
  State<YwbServiceListPage> createState() => _YwbServiceListPageState();
}

class _YwbServiceListPageState extends State<YwbServiceListPage> {
  final scrollAreaKey = GlobalKey();
  final scrollController = ScrollController();

  /// in descending order
  List<YwbService>? metaList;
  bool fetching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refresh();
  }

  Future<void> refresh() async {
    if (!mounted) return;
    setState(() {
      metaList = YwbInit.serviceStorage.serviceList;
      fetching = true;
    });
    try {
      final metaList = await YwbInit.serviceService.getServices();
      metaList.sortBy<num>((e) => -e.count);
      YwbInit.serviceStorage.serviceList = metaList;
      if (!mounted) return;
      setState(() {
        this.metaList = metaList;
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

  @override
  Widget build(BuildContext context) {
    final metaList = this.metaList;
    return Scaffold(
      floatingActionButton: !fetching ? null : const CircularProgressIndicator.adaptive(),
      body: CustomScrollView(
        key: scrollAreaKey,
        controller: scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            title: i18n.title.text(),
            actions: [
              Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: i18n.info,
                child: Icon(context.icons.info).padAll(8),
              ),
            ],
          ),
          if (metaList != null)
            if (metaList.isEmpty)
              SliverFillRemaining(
                child: LeavingBlank(
                  icon: Icons.inbox_outlined,
                  desc: i18n.noServicesTip,
                ),
              )
            else
              SliverList.builder(
                itemCount: metaList.length,
                itemBuilder: (ctx, i) => YwbServiceTile(meta: metaList[i], isHot: i < 3),
              ),
        ],
      ),
    );
  }
}
