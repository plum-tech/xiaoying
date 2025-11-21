import 'package:dio/dio.dart';
import 'package:mimir/utils/strings.dart';

Options disableRedirectFormEncodedOptions({
  Map<String, dynamic>? headers,
  ResponseType? responseType,
}) {
  return Options(
    headers: headers,
    contentType: Headers.formUrlEncodedContentType,
    followRedirects: false,
    responseType: responseType,
    validateStatus: (status) {
      return status! < 400;
    },
  );
}

extension DioEx on Dio {
  Future<Response> processRedirect(
    Response response, {
    Map<String, dynamic>? headers,
    List<Response>? history,
  }) async {
    var cur = response;
    history ??= <Response>[];
    while (true) {
      history.add(cur);
      // Prevent the redirect being processed by HttpClient, with the 302 response caught manually.
      final headerLocations = cur.headers['location'];
      if (cur.statusCode == 302 && headerLocations != null && headerLocations.isNotEmpty) {
        var location = headerLocations[0];
        if (location.isEmpty) return cur;
        final locationUri = Uri.parse(location);
        if (!locationUri.isAbsolute) {
          // to prevent double-slash issue
          location = '${cur.requestOptions.uri.origin.removeSuffix("/")}/${location.removePrefix("/")}';
        }
        cur = await get(
          location,
          options: disableRedirectFormEncodedOptions(
            responseType: cur.requestOptions.responseType,
            headers: headers,
          ),
        );
      } else {
        return cur;
      }
    }
  }

  Future<Response> requestFollowRedirect(
    String url, {
    Map<String, String>? queryParameters,
    dynamic Function()? data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    List<Response>? history,
  }) async {
    history ??= <Response>[];
    final res = await request(
      url,
      queryParameters: queryParameters,
      data: data?.call(),
      options: (options ?? Options()).copyWith(
        followRedirects: false,
      ),
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    history.add(res);
    final finalRes = await processRedirect(
      res,
      history: history,
    );
    return finalRes;
  }
}
