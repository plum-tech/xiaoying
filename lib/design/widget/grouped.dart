import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

typedef HeaderBuilder = Widget Function(
  BuildContext context,
  bool expanded,
  VoidCallback toggleExpand,
  Widget defaultTrailing,
);

class GroupedSection extends StatefulWidget {
  final bool initialExpanded;
  final int itemCount;
  final HeaderBuilder headerBuilder;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const GroupedSection({
    super.key,
    this.initialExpanded = true,
    required this.itemCount,
    required this.itemBuilder,
    required this.headerBuilder,
  });

  @override
  State<GroupedSection> createState() => _GroupedSectionState();
}

class _GroupedSectionState extends State<GroupedSection> {
  late var expanded = widget.initialExpanded;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: Card(
            clipBehavior: Clip.hardEdge,
            child: widget.headerBuilder(
              context,
              expanded,
              () {
                setState(() {
                  expanded = !expanded;
                });
              },
              expanded ? const Icon(Icons.expand_less) : const Icon(Icons.expand_more),
            ),
          ),
        ),
        SliverAnimatedPaintExtent(
          duration: Durations.medium3,
          curve: Curves.fastEaseInToSlowEaseOut,
          child: SliverList(
            delegate: !expanded
                ? const SliverChildListDelegate.fixed([])
                : SliverChildBuilderDelegate(
                    widget.itemBuilder,
                    childCount: widget.itemCount,
                  ),
          ),
        )
      ],
    );
  }
}

class AsyncGroupSection<T> extends StatefulWidget {
  final bool initialExpanded;
  final Widget? title;
  final Widget? subtitle;
  final Future<List<T>> Function() fetch;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  const AsyncGroupSection({
    super.key,
    this.title,
    this.subtitle,
    this.initialExpanded = true,
    required this.fetch,
    required this.itemBuilder,
  });

  @override
  State<AsyncGroupSection<T>> createState() => _AsyncGroupSectionState<T>();
}

class _AsyncGroupSectionState<T> extends State<AsyncGroupSection<T>> {
  late var expanded = widget.initialExpanded;
  List<T>? items;
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialExpanded) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    if (items != null) return;
    setState(() {
      isFetching = true;
    });
    final data = await widget.fetch();
    setState(() {
      items = data;
      isFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = this.items;
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: Card.filled(
            clipBehavior: Clip.hardEdge,
            child: ListTile(
              title: widget.title,
              subtitle: widget.subtitle,
              dense: true,
              onTap: () async {
                setState(() {
                  expanded = !expanded;
                });
                await fetchData();
              },
              trailing: isFetching
                  ? const CircularProgressIndicator.adaptive()
                  : expanded
                      ? const Icon(Icons.expand_less)
                      : const Icon(Icons.expand_more),
            ),
          ),
        ),
        SliverAnimatedPaintExtent(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastEaseInToSlowEaseOut,
          child: SliverList(
            delegate: !expanded || items == null
                ? const SliverChildListDelegate.fixed([])
                : SliverChildBuilderDelegate(
                    childCount: items.length,
                    (ctx, i) {
                      final item = items[i];
                      return widget.itemBuilder(ctx, i, item);
                    },
                  ),
          ),
        )
      ],
    );
  }
}
