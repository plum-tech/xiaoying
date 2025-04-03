import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/widget/common.dart';
import 'package:rettulf/rettulf.dart';

typedef CandidateBuilder<T> = Widget Function(
  BuildContext ctx,
  List<T> matchedItems,
  String query,
  void Function(T item) selectIt,
);
typedef HistoryBuilder<T> = Widget Function(
  BuildContext ctx,
  List<T> items,
  void Function(T item) selectIt,
);
typedef Stringifier<T> = String Function(T item);
typedef QueryProcessor = String Function(String raw);
typedef ItemPredicate<T> = bool Function(String query, T item);
typedef HighlightedCandidateBuilder<T> = Widget Function(
  BuildContext ctx,
  List<T> matchedItems,
  (String full, TextRange highlighted) Function(T item) highlight,
  void Function(T item) selectIt,
);
typedef HighlightedHistoryBuilder<T> = Widget Function(
  BuildContext ctx,
  List<T> items,
  String Function(T item) stringify,
  void Function(T item) selectIt,
);

class ItemSearchDelegate<T> extends SearchDelegate {
  final ({ValueNotifier<List<T>> history, HistoryBuilder<T> builder})? searchHistory;
  final WidgetBuilder? emptyCandidateBuilder;
  final WidgetBuilder? emptyHistoryBuilder;
  final List<T> candidates;
  final CandidateBuilder<T> candidateBuilder;
  final ItemPredicate<T> predicate;
  final QueryProcessor? queryProcessor;
  final double maxCrossAxisExtent;
  final double childAspectRatio;
  final String? invalidSearchTip;

  /// If this is given, it means user can send a empty query without suggestion limitation.
  /// If so, this object will be returned.
  final Object? emptyIndicator;

  ItemSearchDelegate({
    required this.candidateBuilder,
    required this.candidates,
    required this.predicate,
    required this.emptyCandidateBuilder,
    required this.emptyHistoryBuilder,
    this.searchHistory,
    this.queryProcessor,
    required this.maxCrossAxisExtent,
    required this.childAspectRatio,
    this.emptyIndicator,
    this.invalidSearchTip,
    super.keyboardType,
    super.searchFieldLabel,
    super.searchFieldStyle,
    super.searchFieldDecorationTheme,
    super.textInputAction,
  });

  factory ItemSearchDelegate.highlight({
    required HighlightedCandidateBuilder<T> candidateBuilder,
    required List<T> candidates,
    required HighlightedHistoryBuilder<T> historyBuilder,

    /// Using [String.contains] by default.
    ItemPredicate<String>? predicate,
    ValueNotifier<List<T>>? searchHistory,
    QueryProcessor? queryProcessor,
    required double maxCrossAxisExtent,
    required double childAspectRatio,
    Object? emptyIndicator,
    WidgetBuilder? emptyCandidateBuilder,
    WidgetBuilder? emptyHistoryBuilder,
    String? invalidSearchTip,

    /// Using [Object.toString] by default.
    Stringifier<T>? stringifier,
    TextInputType? keyboardType,
    String? searchFieldLabel,
    TextStyle? searchFieldStyle,
    InputDecorationTheme? searchFieldDecorationTheme,
    TextInputAction textInputAction = TextInputAction.search,
  }) {
    return ItemSearchDelegate(
      searchFieldLabel: searchFieldLabel,
      searchFieldStyle: searchFieldStyle,
      searchFieldDecorationTheme: searchFieldDecorationTheme,
      keyboardType: keyboardType,
      maxCrossAxisExtent: maxCrossAxisExtent,
      childAspectRatio: childAspectRatio,
      queryProcessor: queryProcessor,
      candidates: candidates,
      invalidSearchTip: invalidSearchTip,
      emptyIndicator: emptyIndicator,
      emptyCandidateBuilder: emptyCandidateBuilder,
      emptyHistoryBuilder: emptyHistoryBuilder,
      searchHistory: searchHistory == null
          ? null
          : (
              history: searchHistory,
              builder: (ctx, items, selectIt) {
                return historyBuilder(
                  ctx,
                  items,
                  (item) => stringifier?.call(item) ?? item.toString(),
                  selectIt,
                );
              }
            ),
      predicate: (query, item) {
        if (query.isEmpty) return false;
        final candidate = stringifier?.call(item) ?? item.toString();
        if (predicate == null) return candidate.contains(query);
        return predicate(query, candidate);
      },
      candidateBuilder: (ctx, items, query, selectIt) {
        return candidateBuilder(
          ctx,
          items,
          (item) {
            final candidate = stringifier?.call(item) ?? item.toString();
            final highlighted = findSelected(full: candidate, selected: query);
            return (candidate, highlighted);
          },
          selectIt,
        );
      },
    );
  }

  String getRealQuery() => queryProcessor?.call(query) ?? query;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      PlatformIconButton(
        icon: Icon(context.icons.clear),
        onPressed: () => query = "",
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return PlatformIconButton(
      icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final query = getRealQuery();
    if (query.isEmpty && emptyIndicator != null) {
      return const SizedBox.shrink();
    }
    if (T == String && predicate(query, query as T)) {
      if (candidates.contains(query)) {
        return const SizedBox.shrink();
      } else {
        return LeavingBlank(icon: Icons.search_off_rounded, desc: invalidSearchTip);
      }
    }
    return LeavingBlank(icon: Icons.search_off_rounded, desc: invalidSearchTip);
  }

  @override
  void showResults(BuildContext context) {
    super.showResults(context);
    final query = getRealQuery();
    if (query.isEmpty && emptyIndicator != null) {
      close(context, emptyIndicator);
      return;
    }
    if (T == String && predicate(query, query as T) && candidates.contains(query)) {
      close(context, query);
      return;
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final query = getRealQuery();
    final searchHistory = this.searchHistory;
    if (query.isEmpty && searchHistory != null) {
      final (:history, :builder) = searchHistory;
      return history >>
          (ctx, value) {
            if (value.isEmpty && emptyHistoryBuilder != null) {
              return emptyHistoryBuilder!(context);
            }
            return builder(context, value, (item) => close(context, item));
          };
    } else {
      final query = getRealQuery();
      final matched = candidates.where((candidate) => predicate(query, candidate)).toList();
      if (matched.isEmpty && emptyCandidateBuilder != null) {
        return emptyCandidateBuilder!(context);
      }
      return candidateBuilder(context, matched, query, (candidate) => close(context, candidate));
    }
  }
}

TextRange findSelected({
  required String full,
  required String selected,
}) {
  final start = full.indexOf(selected);
  if (start < 0) return TextRange.empty;
  return TextRange(start: start, end: start + selected.length);
}

class HighlightedText extends StatelessWidget {
  final String full;
  final TextRange highlighted;
  final TextStyle? baseStyle;

  const HighlightedText({
    super.key,
    required this.full,
    this.highlighted = TextRange.empty,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = this.baseStyle ?? const TextStyle();
    final plainStyle = baseStyle.copyWith(color: baseStyle.color?.withOpacity(0.5));
    final highlightedStyle = baseStyle.copyWith(color: context.colorScheme.primary, fontWeight: FontWeight.bold);
    return RichText(
      text: TextSpan(
        children: !highlighted.isValid || !highlighted.isNormalized
            ? [
                TextSpan(text: full, style: highlightedStyle),
              ]
            : [
                TextSpan(text: highlighted.textBefore(full), style: plainStyle),
                TextSpan(text: highlighted.textInside(full), style: highlightedStyle),
                TextSpan(text: highlighted.textAfter(full), style: plainStyle),
              ],
      ),
    );
  }
}
