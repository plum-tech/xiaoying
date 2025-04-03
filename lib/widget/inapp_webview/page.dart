import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/adaptive/menu.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/animation/progress.dart';
import 'package:mimir/l10n/common.dart';
import 'package:rettulf/rettulf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';

const _i18n = CommonI18n();

typedef NavigationRule = Future<bool> Function(WebUri uri);

NavigationRule limitOrigin(
  Uri originUri, {
  Future<void> Function(Uri uri)? onBlock,
}) {
  return (uri) async {
    if (uri.scheme != originUri.scheme || uri.host != originUri.host) {
      // cancel the request
      onBlock?.call(uri);
      return false;
    }
    return true;
  };
}

class InAppWebViewPage extends StatefulWidget {
  final WebUri initialUri;
  final NavigationRule? canNavigate;
  final bool enableShare;
  final bool enableOpenInBrowser;
  final CookieJar? cookieJar;

  const InAppWebViewPage({
    super.key,
    required this.initialUri,
    this.canNavigate,
    this.enableShare = true,
    this.enableOpenInBrowser = true,
    this.cookieJar,
  });

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  final webViewKey = GlobalKey();
  String? title;

  InAppWebViewController? controller;
  late InAppWebViewSettings settings;

  PullToRefreshController? pullToRefreshController;
  var progress = 0.0;
  final $url = TextEditingController();

  @override
  void initState() {
    super.initState();

    settings = InAppWebViewSettings(
      transparentBackground: true,
      // prevent flashing on dark mode
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      cacheMode: CacheMode.LOAD_DEFAULT,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true,
    );
    pullToRefreshController = !kIsWeb && UniversalPlatform.isMobile
        ? PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                controller?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                controller?.loadUrl(urlRequest: URLRequest(url: await controller?.getUrl()));
              }
            },
          )
        : null;
    setCookie(widget.initialUri);
  }

  Future<void> setCookie(WebUri uri) async {
    final cookieJar = widget.cookieJar;
    if (cookieJar == null) return;
    final cookieManager = CookieManager.instance();
    final cookies = await cookieJar.loadForRequest(uri);
    for (final cookie in cookies) {
      cookieManager.setCookie(
        url: uri,
        name: cookie.name,
        value: cookie.value,
        path: cookie.path ?? "/",
        domain: cookie.domain,
        expiresDate: cookie.expires?.millisecondsSinceEpoch,
        maxAge: cookie.maxAge,
        isSecure: cookie.secure,
        isHttpOnly: cookie.httpOnly,
        sameSite: cookie.sameSite == null ? null : HTTPCookieSameSitePolicy.fromValue(cookie.sameSite!.name),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final controller = this.controller;
        if (controller == null) return context.pop();
        final canGoBack = await controller.canGoBack();
        if (canGoBack) {
          await controller.goBack();
        } else {
          if (!context.mounted) return;
          return context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 42,
          centerTitle: true,
          titleTextStyle: context.textTheme.titleSmall,
          title: title != null
              ? TextScroll(
                  title,
                  velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                )
              : null,
          leading: PlatformIconButton(
            icon: Icon(context.icons.close, size: 18),
            onPressed: () {
              context.pop();
            },
          ),
          actions: [
            buildAction(),
          ],
        ),
        floatingActionButton: progress < 1.0 ? const AnimatedProgressCircle() : null,
        body: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: widget.initialUri),
          initialSettings: settings,
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) {
            this.controller = controller;
          },
          onLoadStart: (controller, url) async {
            setState(() {
              $url.text = url.toString();
              progress = 0;
            });
            if (url != null) {
              await setCookie(url);
            }
          },
          onLoadStop: (controller, url) async {
            pullToRefreshController?.endRefreshing();
            setState(() {
              $url.text = url.toString();
              progress = 1;
            });
          },
          onTitleChanged: (controller, title) async {
            setState(() {
              this.title = title?.trim();
            });
          },
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url;
            if (uri == null) {
              return NavigationActionPolicy.CANCEL;
            }
            // if (uri.scheme == R.scheme) {
            //   final result = await onHandleDeepLink(context: context, deepLink: uri);
            //   if (result == DeepLinkHandleResult.success) {
            //     return NavigationActionPolicy.CANCEL;
            //   }
            // }
            final canNavigateTo = widget.canNavigate;
            if (canNavigateTo != null && !await canNavigateTo(uri)) {
              return NavigationActionPolicy.CANCEL;
            }
            if (!const ["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
              if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                return NavigationActionPolicy.CANCEL;
              }
            }
            return NavigationActionPolicy.ALLOW;
          },
          onReceivedError: (controller, request, error) {
            pullToRefreshController?.endRefreshing();
          },
          onProgressChanged: (controller, progress) {
            if (progress == 100) {
              pullToRefreshController?.endRefreshing();
            }
            setState(() {
              this.progress = progress / 100;
            });
          },
          onUpdateVisitedHistory: (controller, url, androidIsReload) async {
            setState(() {
              $url.text = url.toString();
            });
          },
          onConsoleMessage: (controller, consoleMessage) {
            if (kDebugMode) {
              print(consoleMessage.message);
            }
          },
        ),
      ),
    );
  }

  Widget buildAction() {
    var actions = 0;
    actions++; // refresh
    if (widget.enableShare) actions++;
    if (widget.enableOpenInBrowser) actions++;
    if (actions <= 1) {
      return PlatformIconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () {
          controller?.reload();
        },
      );
    } else {
      return buildPullDownMenu();
    }
  }

  Widget buildPullDownMenu() {
    return PullDownMenuButton(
      iconBuilder: (ctx, icon) => Icon(icon, size: 18),
      itemBuilder: (ctx) => [
        PullDownItem(
          title: _i18n.refresh,
          icon: context.icons.refresh,
          onTap: () {
            controller?.reload();
          },
        ),
        if (widget.enableShare)
          PullDownItem(
            title: _i18n.share,
            icon: context.icons.share,
            onTap: _onShared,
          ),
        if (widget.enableOpenInBrowser)
          PullDownItem(
            title: _i18n.openInBrowser,
            icon: Icons.open_in_browser,
            onTap: _onOpenInBrowser,
          ),
      ],
    );
  }

  void _onShared() async {
    final url = await controller?.getUrl();
    if (url == null) return;
    await Share.shareUri(url);
  }

  void _onOpenInBrowser() async {
    final url = await controller?.getUrl();
    if (url == null) return;
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}
