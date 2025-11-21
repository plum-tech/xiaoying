import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/design/animation/progress.dart';
import 'package:mimir/design/widget/common.dart';

import 'package:mimir/school/oa_announce/widget/tile.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/utils/collection.dart';
import 'package:mimir/utils/error.dart';

import '../entity/announce.dart';
import '../init.dart';
import '../i18n.dart';

class OaAnnounceListPage extends ConsumerStatefulWidget {
  const OaAnnounceListPage({super.key});

  @override
  ConsumerState<OaAnnounceListPage> createState() => _OaAnnounceListPageState();
}

class _OaAnnounceListPageState extends ConsumerState<OaAnnounceListPage> {
  @override
  Widget build(BuildContext context) {
    final userType = ref.watch(CredentialsInit.storage.oa.$userType);
    final cats = OaAnnounceCat.resolve(userType);
    return OaAnnounceListPageInternal(cats: cats);
  }
}

class OaAnnounceListPageInternal extends StatefulWidget {
  final List<OaAnnounceCat> cats;

  const OaAnnounceListPageInternal({
    super.key,
    required this.cats,
  });

  @override
  State<OaAnnounceListPageInternal> createState() => _OaAnnounceListPageInternalState();
}

class _OaAnnounceListPageInternalState extends State<OaAnnounceListPageInternal> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.cats.length,
      child: Scaffold(
        appBar: AppBar(
          title: i18n.title.text(),
          bottom: TabBar(
            isScrollable: true,
            tabs: widget.cats
                .map((cat) => Tab(
                      child: cat.l10nName().text(),
                    ))
                .toList(),
          ),
        ),
        body: TabBarView(
          // These are the contents of the tab views, below the tabs.
          children: widget.cats.mapIndexed((i, cat) {
            return OaAnnounceLoadingList(
              key: ValueKey(cat),
              cat: cat,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class OaAnnounceLoadingList extends StatefulWidget {
  final OaAnnounceCat cat;

  const OaAnnounceLoadingList({
    super.key,
    required this.cat,
  });

  @override
  State<OaAnnounceLoadingList> createState() => _OaAnnounceLoadingListState();
}

class _OaAnnounceLoadingListState extends State<OaAnnounceLoadingList> with AutomaticKeepAliveClientMixin {
  int lastPage = 1;
  bool fetching = false;
  late var announcements = OaAnnounceInit.storage.getAnnouncements(widget.cat);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) async {
      await loadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final announcements = this.announcements;
    return NotificationListener<ScrollNotification>(
      onNotification: (event) {
        if (event.metrics.pixels >= event.metrics.maxScrollExtent) {
          loadMore();
        }
        return true;
      },
      child: announcements == null
          ? const SizedBox()
          : WhenLoading(
              loading: fetching,
              child: buildList(announcements),
            ),
    );
  }

  Widget buildList(List<OaAnnounceRecord> announcements) {
    return announcements.isEmpty
        ? LeavingBlank(
            icon: Icons.inbox_outlined,
            desc: i18n.noOaAnnouncementsTip,
          )
        : ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (ctx, index) {
              return Card.filled(
                clipBehavior: Clip.hardEdge,
                child: OaAnnounceTile(announcements[index]),
              );
            },
          );
  }

  Future<void> loadMore() async {
    if (fetching) return;
    if (!mounted) return;
    setState(() {
      fetching = true;
    });
    final cat = widget.cat;
    try {
      final lastPayload = await OaAnnounceInit.service.getAnnounceList(cat, lastPage);
      final announcements = this.announcements ?? <OaAnnounceRecord>[];
      announcements.addAll(lastPayload.items);
      announcements.distinctBy((a) => a.uuid);
      announcements.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      await OaAnnounceInit.storage.setAnnouncements(cat, announcements);
      if (!mounted) return;
      setState(() {
        lastPage = max(lastPage + 1, lastPayload.totalPage);
        this.announcements = announcements;
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
