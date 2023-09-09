import 'package:auto_animated/auto_animated.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mimir/design/animation/livelist.dart';
import 'package:mimir/design/colors.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/list.dart';
import '../init.dart';
import '../widgets/activity.dart';
import '../widgets/search.dart';
import '../i18n.dart';

class ActivityListPage extends StatefulWidget {
  const ActivityListPage({super.key});

  @override
  State<StatefulWidget> createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> with SingleTickerProviderStateMixin {
  static const categories = [
    Class2ndActivityType.lecture,
    Class2ndActivityType.creation,
    Class2ndActivityType.thematicEdu,
    Class2ndActivityType.schoolCulture,
    Class2ndActivityType.practice,
    Class2ndActivityType.voluntary,
  ];

  late TabController _tabController;

  final $page = ValueNotifier(0);
  bool init = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: categories.length,
      vsync: this,
    );
    _tabController.addListener(() => $page.value = _tabController.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: buildBody(),
    );
  }

  Widget buildBody() {
    return Scaffold(
      appBar: AppBar(
        title: i18n.activity.title.text(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: ActivitySearchDelegate()),
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: categories.mapIndexed((i, e) {
            return $page >>
                (ctx, page) {
                  return Tab(
                    child: e.name.text(
                      style: page == i ? TextStyle(color: ctx.textColor) : ctx.theme.textTheme.bodyLarge,
                    ),
                  );
                };
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((selectedActivityType) {
          return ValueListenableBuilder(
            valueListenable: $page,
            builder: (context, index, child) {
              return ActivityList(selectedActivityType);
            },
          );
        }).toList(),
      ),
    );
  }
}

///
/// Thanks to the cache, don't worry about that switching tab will re-fetch the activity list.
class ActivityList extends StatefulWidget {
  final Class2ndActivityType type;

  const ActivityList(this.type, {super.key});

  @override
  State<StatefulWidget> createState() => _ActivityListState();
}

/// Note: Changing orientation will cause a rebuild.
/// The solution is to use any state manager framework, such as `provider`.
class _ActivityListState extends State<ActivityList> {
  int _lastPage = 1;
  bool _atEnd = false;
  List<Class2ndActivity> _activityList = [];

  bool loading = true;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!_atEnd) {
          loadMoreActivities();
        }
      } else {
        setState(() {
          _atEnd = false;
        });
      }
    });
    loadInitialActivities();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CircularProgressIndicator();
    } else {
      return buildActivityResult(_activityList);
    }
  }

  void loadInitialActivities() async {
    if (!mounted) return;
    setState(() {
      _lastPage = 1;
    });
    final activities = await Class2ndInit.activityListService.getActivityList(widget.type, 1);
    if (activities != null) {
      if (!mounted) return;
      setState(() {
        // The incoming activities may be the same as before, so distinct is necessary.
        activities.distinctBy((a) => a.id);
        _activityList = activities;
        _lastPage++;
        loading = false;
      });
    }
  }

  void loadMoreActivities() async {
    if (_atEnd) return;

    final lastActivities = await Class2ndInit.activityListService.getActivityList(widget.type, _lastPage);

    if (!mounted) return;
    if (lastActivities != null) {
      if (lastActivities.isEmpty) {
        setState(() => _atEnd = true);
      } else {
        setState(() {
          _lastPage++;
          _activityList.addAll(lastActivities);
          // The incoming activities may be the same as before, so distinct is necessary.
          _activityList.distinctBy((a) => a.id);
        });
      }
    }
  }

  Widget buildActivityResult(List<Class2ndActivity> activities) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: activities.length,
      itemBuilder: (ctx, index) => ActivityCard(activities[index]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}

extension DistinctEx<E> on List<E> {
  List<E> distinct({bool inplace = true}) {
    final ids = <E>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(x));
    return list;
  }

  List<E> distinctBy<Id>(Id Function(E element) id, {bool inplace = true}) {
    final ids = <Id>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id(x)));
    return list;
  }
}
