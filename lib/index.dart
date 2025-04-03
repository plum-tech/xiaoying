import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/timetable/i18n.dart' as $timetable;
import 'package:mimir/school/i18n.dart' as $school;

import 'package:rettulf/rettulf.dart';

class MainStagePage extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainStagePage({super.key, required this.navigationShell});

  @override
  ConsumerState<MainStagePage> createState() => _MainStagePageState();
}

typedef _NavigationDest = ({IconData icon, IconData activeIcon, String label});

extension _NavigationDestX on _NavigationDest {
  NavigationDestination toBarItem() {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(activeIcon),
      label: label,
    );
  }

  NavigationRailDestination toRailDest() {
    return NavigationRailDestination(
      icon: Icon(icon),
      selectedIcon: Icon(activeIcon),
      label: label.text(),
    );
  }
}

typedef NavigationItems = List<({String route, _NavigationDest item})>;

class _MainStagePageState extends ConsumerState<MainStagePage> {
  NavigationItems buildItems() {
    return [
      (
        route: "/timetable",
        item: (
          icon: Icons.calendar_month_outlined,
          activeIcon: Icons.calendar_month,
          label: $timetable.i18n.navigation,
        )
      ),
      if (!kIsWeb)
        (
          route: "/school",
          item: (
            icon: Icons.school_outlined,
            activeIcon: Icons.school,
            label: $school.i18n.navigation,
          )
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = buildItems();
    if (context.isPortrait) {
      return Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: buildNavigationBar(items),
      );
    } else {
      return Scaffold(
        body: [
          buildNavigationRail(items),
          const VerticalDivider(),
          widget.navigationShell.expanded(),
        ].row(),
      );
    }
  }

  Widget buildNavigationBar(NavigationItems items) {
    return NavigationBar(
      selectedIndex: getSelectedIndex(items),
      onDestinationSelected: (index) => onItemTapped(index, items),
      destinations: items.map((e) => e.item.toBarItem()).toList(),
    );
  }

  Widget buildNavigationRail(NavigationItems items) {
    return NavigationRail(
      labelType: NavigationRailLabelType.all,
      selectedIndex: getSelectedIndex(items),
      onDestinationSelected: (index) => onItemTapped(index, items),
      destinations: items.map((e) => e.item.toRailDest()).toList(),
    );
  }

  int getSelectedIndex(NavigationItems items) {
    final location = GoRouterState.of(context).uri.toString();
    return max(0, items.indexWhere((item) => location.startsWith(item.route)));
  }

  void onItemTapped(int index, NavigationItems items) {
    final item = items[index];
    final branchIndex = widget.navigationShell.route.routes.indexWhere((r) {
      if (r is GoRoute) {
        return r.path.startsWith(item.route);
      }
      return false;
    });
    widget.navigationShell.goBranch(
      branchIndex >= 0 ? branchIndex : index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
