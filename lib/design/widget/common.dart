import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rettulf/rettulf.dart';

class LeavingBlank extends StatelessWidget {
  final WidgetBuilder iconBuilder;
  final String? desc;
  final Widget? subtitle;
  final Widget? action;

  const LeavingBlank.builder({
    super.key,
    required this.iconBuilder,
    required this.desc,
    this.subtitle,
    this.action,
  });

  factory LeavingBlank({
    Key? key,
    required IconData icon,
    String? desc,
    double size = 120,
    Widget? subtitle,
    Widget? action,
  }) {
    return LeavingBlank.builder(
      iconBuilder: (ctx) => icon.make(size: size, color: ctx.colorScheme.primary),
      desc: desc,
      subtitle: subtitle,
      action: action,
    );
  }

  factory LeavingBlank.svgAssets({
    Key? key,
    required String assetName,
    String? desc,
    VoidCallback? onIconTap,
    double width = 120,
    double height = 120,
    Widget? subtitle,
    Widget? action,
  }) {
    return LeavingBlank.builder(
      iconBuilder: (ctx) => SvgPicture.asset(assetName, width: width, height: height),
      desc: desc,
      subtitle: subtitle,
      action: action,
    );
  }

  @override
  Widget build(BuildContext context) {
    final desc = this.desc;
    final action = this.action;
    final subtitle = this.subtitle;
    Widget icon = iconBuilder(context).padAll(20);
    return [
      icon,
      if (desc != null) buildDesc(context, desc),
      if (subtitle != null) subtitle,
      if (action != null) action,
    ].column(maa: MainAxisAlignment.spaceAround, mas: MainAxisSize.min).center();
  }

  Widget buildDesc(BuildContext ctx, String desc) {
    return desc
        .text(
          style: ctx.textTheme.titleLarge,
          textAlign: TextAlign.center,
        )
        .center()
        .padAll(10);
  }
}
