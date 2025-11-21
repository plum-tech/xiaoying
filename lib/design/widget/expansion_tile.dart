import 'package:flutter/material.dart';

// thanks to "https://github.com/simplewidgets/rounded_expansion_tile"
const _kDefaultDuration = Durations.medium4;

class AnimatedExpansionTile extends StatefulWidget {
  final List<Widget> children;
  final bool? autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final bool? dense;
  final bool? enabled;
  final bool? enableFeedback;
  final Color? focusColor;
  final FocusNode? focusNode;
  final double? horizontalTitleGap;
  final Color? hoverColor;
  final bool? isThreeLine;
  final Widget? leading;
  final double? minLeadingWidth;
  final double? minVerticalPadding;
  final MouseCursor? mouseCursor;
  final void Function()? onLongPress;
  final bool? selected;
  final Color? selectedTileColor;
  final ShapeBorder? shape;
  final Widget? subtitle;
  final Widget? title;
  final Color? tileColor;
  final Widget? trailing;
  final VisualDensity? visualDensity;
  final Duration? duration;
  final Curve? fadeCurve;
  final Curve? sizeCurve;
  final EdgeInsets? childrenPadding;
  final bool? rotateTrailing;
  final bool? noTrailing;
  final bool initiallyExpanded;

  const AnimatedExpansionTile({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.duration,
    this.autofocus,
    this.contentPadding,
    this.dense,
    this.enabled,
    this.enableFeedback,
    this.focusColor,
    this.focusNode,
    this.horizontalTitleGap,
    this.hoverColor,
    this.isThreeLine,
    this.minLeadingWidth,
    this.minVerticalPadding,
    this.mouseCursor,
    this.onLongPress,
    this.selected,
    this.selectedTileColor,
    this.shape,
    this.tileColor,
    this.visualDensity,
    this.childrenPadding,
    this.rotateTrailing,
    this.noTrailing,
    this.initiallyExpanded = false,
    this.fadeCurve,
    this.sizeCurve,
  });

  @override
  AnimatedExpansionTileState createState() => AnimatedExpansionTileState();
}

class AnimatedExpansionTileState extends State<AnimatedExpansionTile> with TickerProviderStateMixin {
  late bool _expanded;
  bool? _rotateTrailing;
  bool? _noTrailing;
  late AnimationController _iconController;

  // When the duration of the ListTile animation is NOT provided. This value will be used instead.

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    // If not provided, this will be true
    _rotateTrailing = widget.rotateTrailing ?? true;
    // If not provided this will be false
    _noTrailing = widget.noTrailing ?? false;

    _iconController = AnimationController(
      duration: widget.duration ?? _kDefaultDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    if (mounted) {
      _iconController.dispose();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          // If bool is not provided the default will be false.
          autofocus: widget.autofocus ?? false,
          contentPadding: widget.contentPadding,
          // If bool is not provided the default will be false.
          dense: widget.dense,
          // If bool is not provided the default will be true.
          enabled: widget.enabled ?? true,
          enableFeedback:
              // If bool is not provided the default will be false.
              widget.enableFeedback ?? false,
          focusColor: widget.focusColor,
          focusNode: widget.focusNode,
          horizontalTitleGap: widget.horizontalTitleGap,
          hoverColor: widget.hoverColor,
          // If bool is not provided the default will be false.
          isThreeLine: widget.isThreeLine ?? false,
          key: widget.key,
          leading: widget.leading,
          minLeadingWidth: widget.minLeadingWidth,
          minVerticalPadding: widget.minVerticalPadding,
          mouseCursor: widget.mouseCursor,
          onLongPress: widget.onLongPress,
          // If bool is not provided the default will be false.
          selected: widget.selected ?? false,
          selectedTileColor: widget.selectedTileColor,
          shape: widget.shape,
          subtitle: widget.subtitle,
          title: widget.title,
          tileColor: widget.tileColor,
          trailing: _noTrailing! ? null : _trailingIcon(),
          visualDensity: widget.visualDensity,
          onTap: () {
            setState(() {
              // Checks if the ListTile is expanded and sets state accordingly.
              if (_expanded) {
                _expanded = !_expanded;
                _iconController.reverse();
              } else {
                _expanded = !_expanded;
                _iconController.forward();
              }
            });
          },
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: widget.childrenPadding ?? EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: widget.children.length,
          itemBuilder: (ctx, i) => AnimatedCrossFade(
            duration: widget.duration ?? _kDefaultDuration,
            firstCurve: widget.fadeCurve ?? Curves.linear,
            sizeCurve: widget.sizeCurve ?? Curves.fastEaseInToSlowEaseOut,
            firstChild: widget.children[i],
            secondChild: const SizedBox.shrink(),
            crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          ),
        ),
      ],
    );
  }

  // Build trailing widget based on the user input.
  Widget? _trailingIcon() {
    final trailing = widget.trailing ?? const Icon(Icons.keyboard_arrow_down);
    if (_rotateTrailing!) {
      return RotationTransition(turns: Tween(begin: 0.0, end: 0.5).animate(_iconController), child: trailing);
    } else {
      // If developer sets rotateTrailing to false the widget will just be returned.
      return trailing;
    }
  }
}
