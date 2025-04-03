import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/utils/error.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> guardLaunchUrl(BuildContext ctx, Uri url) async {
  if (url.scheme == "http" || url.scheme == "https") {
    try {
      // guards the http(s)
      if (kIsWeb || UniversalPlatform.isDesktop) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      final target = Uri(
        path: "/webview",
        queryParameters: {"url": url.toString()},
      ).toString();
      ctx.push(target);
      return true;
    } catch (error, stackTrace) {
      debugPrintError(error, stackTrace);
      return false;
    }
  }
  // not http(s)
  try {
    return await launchUrl(url);
  } catch (error, stackTrace) {
    debugPrintError(error, stackTrace);
    return false;
  }
}

Future<bool> guardLaunchUrlString(BuildContext ctx, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return await guardLaunchUrl(ctx, uri);
}
