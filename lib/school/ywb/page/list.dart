import 'package:auto_animated/auto_animated.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mimir/design/adaptive/adaptive.dart';
import 'package:mimir/design/animation/livelist.dart';
import 'package:mimir/design/widgets/dialog.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/application.dart';
import '../init.dart';
import '../widgets/application.dart';
import "package:mimir/credential/widgets/oa_scope.dart";
import '../i18n.dart';

// 本科生常用功能列表
const Set<String> _commonUsed = <String>{
  '121',
  '011',
  '047',
  '123',
  '124',
  '024',
  '125',
  '165',
  '075',
  '202',
  '023',
  '067',
  '059'
};

class YwbListPage extends StatefulWidget {
  const YwbListPage({super.key});

  @override
  State<YwbListPage> createState() => _YwbListPageState();
}

class _YwbListPageState extends State<YwbListPage> with AdaptivePageProtocol {
  final $enableFilter = ValueNotifier(false);
  final service = YwbInit.applicationService;

  // in descending order
  List<ApplicationMeta> _allDescending = [];
  String? _lastError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _fetchMetaList().then((value) {
      if (value != null) {
        if (!mounted) return;
        value.sortBy<num>((e) => -e.count); // descending
        setState(() {
          _allDescending = value;
          _lastError = null;
        });
      }
    }).onError((error, stackTrace) {
      if (!mounted) return;
      setState(() {
        _lastError = error.toString();
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: "Ywb".text(),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () async {
                await context.showTip(
                  title: i18n.title,
                  desc: i18n.desc,
                  ok: i18n.close,
                );
              },
            ),
            IconButton(
              icon: $enableFilter.value ? const Icon(Icons.filter_alt_outlined) : const Icon(Icons.filter_alt_off_outlined),
              tooltip: i18n.filerInfrequentlyUsed,
              onPressed: () {
                setState(() {
                  $enableFilter.value = !$enableFilter.value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPortrait(BuildContext context) {
    final lastError = _lastError;
    if (lastError != null) {
      return lastError.text().center();
    } else if (_allDescending.isNotEmpty) {
      return buildListPortrait(_allDescending);
    } else {
      return const CircularProgressIndicator();
    }
  }

  Widget buildBodyPortrait() {
    final lastError = _lastError;
    if (lastError != null) {
      return lastError.text().center();
    } else if (_allDescending.isNotEmpty) {
      return buildListPortrait(_allDescending);
    } else {
      return const CircularProgressIndicator();
    }
  }

  List<Widget> buildApplications(List<ApplicationMeta> all, bool enableFilter) {
    return all
        .where((element) => !enableFilter || _commonUsed.contains(element.id))
        .mapIndexed((i, e) => ApplicationTile(meta: e, isHot: i < 3).hero(e.id))
        .toList();
  }

  Widget buildListPortrait(List<ApplicationMeta> list) {
    return $enableFilter >>
        (ctx, v) {
          final items = buildApplications(list, v);
          return LiveList(
            showItemInterval: const Duration(milliseconds: 40),
            itemCount: items.length,
            itemBuilder: (ctx, index, animation) => items[index].aliveWith(animation),
          );
        };
  }

  Widget buildLandscape(BuildContext context) {
    final lastError = _lastError;
    if (lastError != null) {
      return lastError.text().center();
    } else if (_allDescending.isNotEmpty) {
      return AdaptiveNavigation(child: buildListLandscape(_allDescending));
    } else {
      return const CircularProgressIndicator();
    }
  }

  Widget buildListLandscape(List<ApplicationMeta> list) {
    return $enableFilter >>
        (ctx, v) {
          final items = buildApplications(list, v);
          return LiveGrid.options(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisExtent: 70,
            ),
            options: commonLiveOptions,
            itemBuilder: (ctx, index, animation) => items[index].aliveWith(animation),
          );
        };
  }

  Future<List<ApplicationMeta>?> _fetchMetaList() async {
    final oaCredential = context.auth.credentials;
    if (oaCredential == null) return null;
    if (!YwbInit.session.isLogin) {
      await YwbInit.session.login(
        username: oaCredential.account,
        password: oaCredential.password,
      );
    }
    return await service.getApplicationMetas();
  }
}
