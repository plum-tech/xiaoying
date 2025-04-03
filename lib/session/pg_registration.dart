import 'package:dio/dio.dart';

import 'package:mimir/session/sso.dart';

/// gms.sit.edu.cn
/// Student registration system for postgraduate
class PgRegistrationSession {
  final SsoSession ssoSession;

  const PgRegistrationSession({required this.ssoSession});

  Future<Response> request(
    String url, {
    Map<String, String>? para,
    dynamic Function()? data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    Future<Response> fetch() async {
      return await ssoSession.request(
        url,
        queryParameters: para,
        data: data,
        options: (options ?? Options()).copyWith(
          contentType: Headers.formUrlEncodedContentType,
        ),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    }

    final response = await fetch();
    final content = response.data;
    if (content is String && content.contains("正在登录") == true) {
      await authGmsService();
      return await fetch();
    }
    return response;
  }

  Future<bool> authGmsService() async {
    final authRes = await ssoSession.request(
      "https://authserver.sit.edu.cn/authserver/login?service=http%3A%2F%2Fgms.sit.edu.cn%2Fepstar%2Fweb%2Fswms%2Fmainframe%2Fhome%2Findex.jsp",
    );
    return authRes.statusCode == 302;
  }
}
