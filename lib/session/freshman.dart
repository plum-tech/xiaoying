import 'package:mimir/credentials/init.dart';
import 'package:mimir/init.dart';
import 'package:mimir/session/sso.dart';
import 'package:dio/dio.dart';
import 'package:mimir/utils/dio.dart';

class FreshmanSession {
  SsoSession get _ssoSession => Init.ssoSession;

  Dio get _dio => Init.schoolDio;

  const FreshmanSession();

  Future<Response> request(
    String url, {
    Map<String, String>? queryParameters,
    dynamic Function()? data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    Future<Response> fetch() async {
      return await _dio.request(
        url,
        queryParameters: queryParameters,
        data: data?.call(),
        options: (options ?? Options()).copyWith(
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    }

    var res = await fetch();
    if (_isLoginRequired(res)) {
      final account = CredentialsInit.storage.oa.credentials!.account;
      await _ssoSession.ssoAuth("http://freshman.sit.edu.cn/yyyx/sso/login.jsp");
      await _dio.requestFollowRedirect(
        "http://freshman.sit.edu.cn/yyyx/loginAction.do?method=login&name=$account&password=111111",
        options: Options(
          method: "POST",
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
    }
    res = await fetch();
    return res;
  }

  bool _isLoginRequired(Response response) {
    if (response.statusCode == 302) return true;
    final data = response.data;
    if (data is String && data.contains("请输入用户名和密码")) {
      return true;
    }
    return false;
  }
}
