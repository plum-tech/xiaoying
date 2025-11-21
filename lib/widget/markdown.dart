import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart';

import 'html.dart';

class FeaturedMarkdownWidget extends StatefulWidget {
  final String data;
  final bool async;
  final Uri? baseUri;
  final bool enableGoRoute;

  const FeaturedMarkdownWidget({
    super.key,
    required this.data,
    this.async = false,
    this.baseUri,
    this.enableGoRoute = true,
  });

  @override
  State<FeaturedMarkdownWidget> createState() => _FeaturedMarkdownWidgetState();
}

class _FeaturedMarkdownWidgetState extends State<FeaturedMarkdownWidget> with AutomaticKeepAliveClientMixin {
  late String html;

  @override
  void initState() {
    super.initState();
    html = buildHtml();
  }

  @override
  void didUpdateWidget(FeaturedMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      setState(() {
        html = buildHtml();
      });
    }
  }

  String buildHtml() {
    return markdownToHtml(
      widget.data,
      extensionSet: ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [
        LineBreakSyntax(),
        AutolinkSyntax(),
        EmailAutolinkSyntax(),
        ImageSyntax(),
        EscapeSyntax(),
        EmphasisSyntax.asterisk(),
        EmphasisSyntax.underscore(),
      ],
      blockSyntaxes: const [
        OrderedListSyntax(),
        UnorderedListSyntax(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RestyledHtmlWidget(
      html,
      async: widget.async,
      keepOriginalFontSize: true,
      baseUri: widget.baseUri,
      enableGoRoute: widget.enableGoRoute,
    );
  }
}
