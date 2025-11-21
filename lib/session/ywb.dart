import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:mimir/credentials/error.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/init.dart';
import 'package:mimir/session/sso.dart';

class YwbSession {
  // ywb is behind school network, requiring VPN for access
  // 应网办 official website
  // static const base = "https://ywb.sit.edu.cn";
  static const base = "https://xgfy.sit.edu.cn";
  bool isLogin = false;
  String? username;
  String? jwtToken;
  final Dio dio;

  YwbSession({
    required this.dio,
  });

  Future<bool> checkConnectivity({
    // String url = "https://ywb.sit.edu.cn/v1",
    String url = "https://xgfy.sit.edu.cn",
  }) async {
    try {
      await Init.dioNoCookie.request(
        url,
        options: Options(
          method: "GET",
          sendTimeout: const Duration(milliseconds: 5000),
          receiveTimeout: const Duration(milliseconds: 5000),
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _login({
    required String username,
    required String password,
  }) async {
    final response = await dio.post(
      "$base/unifri-flow/login",
      data: {
        'account': username,
        'userPassword': password,
        'remember': 'true',
      },
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
    final resData = response.data as Map;
    final int code = resData['code'];

    if (code != 0) {
      final String errMessage = resData['msg'];
      throw CredentialException(type: CredentialErrorType.accountPassword, message: '($code) $errMessage');
    }
    jwtToken = resData['data']['authorization'];
    this.username = username;
    isLogin = true;
  }

  /// 获取当前以毫秒为单位的时间戳.
  static String _getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// 为时间戳生成签名. 此方案是联鹏习惯的反爬方式.
  static String _sign(String ts) {
    final content = const Utf8Encoder().convert('unifri.com$ts');
    return md5.convert(content).toString();
  }

  Future<Response> request(
    String url, {
    Map<String, String>? para,
    dynamic data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (!isLogin) {
      final credentials = CredentialsInit.storage.oa.credentials;
      if (credentials == null) throw OaCredentialsRequiredException(url: url);
      await _login(
        username: credentials.account,
        password: credentials.password,
      );
    }

    Options newOptions = options ?? Options();

    // Make default options.
    final String ts = _getTimestamp();
    final String sign = _sign(ts);
    final Map<String, dynamic> newHeaders = {
      'timestamp': ts,
      'signature': sign,
      'Authorization': jwtToken,
    };

    newOptions.headers == null ? newOptions.headers = newHeaders : newOptions.headers?.addAll(newHeaders);
    newOptions.method = options?.method;

    final response = await dio.request(
      url,
      queryParameters: para,
      data: data,
      options: newOptions,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }
}
