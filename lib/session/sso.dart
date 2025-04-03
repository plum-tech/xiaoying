import 'dart:math';

import 'package:async_locks/async_locks.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:collection/collection.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:logger/logger.dart';
import 'package:mimir/credentials/entity/credential.dart';
import 'package:mimir/credentials/entity/login_status.dart';
import 'package:mimir/credentials/error.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/init.dart';
import 'package:mimir/lifecycle.dart';
import 'package:mimir/login/utils.dart';
import 'package:mimir/r.dart';

import 'package:encrypt/encrypt.dart';

import '../utils/dio.dart';

enum LoginCancelReason {
  captcha,
  invalidCredentials,
  ;
}

class LoginCancelledException implements Exception {
  final LoginCancelReason reason;

  const LoginCancelledException(this.reason);
}

class OaCredentialsRequiredException implements Exception {
  final String url;

  const OaCredentialsRequiredException({required this.url});

  @override
  String toString() {
    return "OaCredentialsRequiredException: $url";
  }
}

const _neededHeaders = {
  "Accept-Encoding": "gzip, deflate, br",
  'Origin': 'https://authserver.sit.edu.cn',
  "Upgrade-Insecure-Requests": "1",
  "Sec-Fetch-Dest": "document",
  "Sec-Fetch-Mode": "navigate",
  "Sec-Fetch-Site": "same-origin",
  "Sec-Fetch-User": "?1",
};

final networkLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 8,
    // Number of method calls to be displayed
    errorMethodCount: 8,
    // Print an emoji for each log message
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Should each log print contain a timestamp
  ),
);

/// Single Sign-On
class SsoSession {
  static const String _authServerUrl = 'https://authserver.sit.edu.cn/authserver';
  static const String _loginUrl = '$_authServerUrl/login';
  static const String _needCaptchaUrl = '$_authServerUrl/needCaptcha.html';
  static const String _captchaUrl = '$_authServerUrl/captcha.html';
  static const String _loginSuccessUrl = 'https://authserver.sit.edu.cn/authserver/index.do';

  Dio get _dio => Init.schoolDio;

  CookieJar get _cookieJar => Init.schoolCookieJar;

  /// Input captcha manually
  final Future<String?> Function(Uint8List imageBytes) inputCaptcha;

  /// Lock it to prevent simultaneous login.
  static final _loginLock = Lock();

  /// Lock all requests through SSO.
  static final _ssoLock = Lock();

  SsoSession({
    required this.inputCaptcha,
  });

  Future<bool> checkConnectivity({
    String url = "https://myportal.sit.edu.cn/",
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
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkAuthStatus() async {
    final res = await _dio.requestFollowRedirect(
      "https://myportal.sit.edu.cn/",
    );
    return !_isLoginRequired(res);
  }

  /// - User try to log in actively on a login page.
  Future<Response> loginLocked(
    Credential credentials, {
    bool active = false,
  }) async {
    return await _loginLock.run(() async {
      networkLogger.i("loginLocked ${DateTime.now().toIso8601String()}");
      try {
        return await _login(
          credentials,
          inputCaptcha: inputCaptcha,
        );
      } catch (error, stackTrace) {
        if (error is CredentialException) {
          await () async {
            if (active) return;
            final navigateCtx = $key.currentContext;
            if (navigateCtx == null) return;
            if (error.type == CredentialErrorType.accountPassword && CredentialsInit.storage.oa.credentials != null) {
              CredentialsInit.storage.oa.loginStatus = OaLoginStatus.everLogin;
              if (!navigateCtx.mounted) return;
              await handleOaPasswordIncorrectException(context: navigateCtx);
            } else {
              if (!navigateCtx.mounted) return;
              await handleLoginException(
                context: navigateCtx,
                error: error,
                stackTrace: stackTrace,
              );
            }
          }();
        }
        rethrow;
      }
    });
  }

  Future<Response> _request(
    String url, {
    Map<String, String>? queryParameters,
    dynamic Function()? data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final debugDepths = <Response>[];
    Future<Response> fetch() async {
      debugDepths.clear();
      final response = await _dio.request(
        url,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(
          followRedirects: false,
          headers: _neededHeaders,
        ),
        data: data?.call(),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      final finalResponse = await _dio.processRedirect(
        response,
        history: debugDepths,
      );
      return finalResponse;
    }

    // request normally at first
    var res = await fetch();

    // check if the response is the login page. if so, login it first.
    if (_isLoginRequired(res)) {
      final credentials = CredentialsInit.storage.oa.credentials;
      if (credentials == null) {
        throw OaCredentialsRequiredException(url: url);
      }
      await _cookieJar.delete(R.authServerUri, true);
      await _cookieJar.delete(R.sitUri, true);
      await _cookieJar.delete(Uri.parse(url), true);
      await loginLocked(credentials);
      res = await fetch();
    }
    return res;
  }

  Future<Response> ssoAuth(
    String url,
  ) async {
    final authorized = await checkAuthStatus();
    if (!authorized) {
      await loginLocked(CredentialsInit.storage.oa.credentials!);
    }
    // sso
    final res = await _dio.requestFollowRedirect(url);
    return res;
  }

  bool _isLoginRequired(Response res) {
    return res.realUri.toString().contains(_loginUrl);
  }

  Future<Cookie?> getJSessionId() async {
    final cookies = await Init.schoolCookieJar.loadForRequest(Uri.parse(_authServerUrl));
    return cookies.firstWhereOrNull((cookie) => cookie.name == "JSESSIONID");
  }

  Future<Response> _login(
    Credential credentials, {
    required Future<String?> Function(Uint8List imageBytes) inputCaptcha,
  }) async {
    debugPrint('${credentials.account} logging in');
    debugPrint('UA: ${_dio.options.headers['User-Agent']}');
    // When logging into OA,
    // the server will record the number of times a user has logged in with the same cookie
    // and the number of times the user made an input error,
    // so it is necessary to clear all cookies before logging in to avoid errors when the user retries.
    await _cookieJar.delete(R.authServerUri, true);
    // await cookieJar.delete(R.authServerUri, true);
    final Response response;
    try {
      // get AuthServer homepage
      final html = await _fetchAuthServerHtml();
      var captcha = '';
      if (await isCaptchaRequired(credentials.account)) {
        final captchaImage = await getCaptcha();
        captcha = await getInputtedCaptcha(captchaImage, inputCaptcha);
      }
      // get casTicket
      final casTicket = _extractCasTicketFromAuthHtml(html);
      // get salt
      final salt = _extractSaltFromAuthHtml(html);
      // encrypt password
      final hashedPwd = _hashPassword(salt, credentials.password);
      // login and get cookie
      response = await _postLoginRequest(credentials.account, hashedPwd, captcha, casTicket);
    } catch (e) {
      rethrow;
    }
    final pageRaw = response.data as String;
    if (pageRaw.contains("完善资料")) {
      throw CredentialException(message: pageRaw, type: CredentialErrorType.oaIncompleteUserInfo);
    }
    final page = BeautifulSoup(pageRaw);
    // For desktop
    final authError = page.find('span', id: 'msg', class_: 'auth_error')?.text.trim() ?? "";
    // For mobile
    final mobileError = page.find('span', id: 'errorMsg')?.text.trim() ?? "";
    if (authError.isNotEmpty || mobileError.isNotEmpty) {
      final errorMessage = authError + mobileError;
      final type = _parseInvalidType(errorMessage);
      throw CredentialException(message: errorMessage, type: type);
    }

    if (response.realUri.toString() != _loginSuccessUrl) {
      debugPrint('Unknown auth error at "${response.realUri}"');
      throw Exception(response.data.toString());
    }
    debugPrint('${credentials.account} logged in');
    CredentialsInit.storage.oa.lastAuthTime = DateTime.now();
    return response;
  }

  Future<String> getInputtedCaptcha(
    Uint8List captchaImage,
    Future<String?> Function(Uint8List imageBytes) inputCaptcha,
  ) async {
    final c = await inputCaptcha(captchaImage);
    if (c != null) {
      debugPrint("Captcha entered is $c");
      return c;
    } else {
      throw const LoginCancelledException(LoginCancelReason.captcha);
    }
  }

  Future<void> deleteSitUriCookies() async {
    for (final uri in R.sitUriList) {
      await _cookieJar.delete(uri, true);
    }
  }

  static CredentialErrorType _parseInvalidType(String errorMessage) {
    if (errorMessage.contains("验证码")) {
      return CredentialErrorType.captcha;
    } else if (errorMessage.contains("冻结")) {
      return CredentialErrorType.oaFrozen;
    } else if (errorMessage.contains("锁定")) {
      return CredentialErrorType.oaLocked;
    }
    return CredentialErrorType.accountPassword;
  }

  /// Extract the Salt from the auth page
  String _extractSaltFromAuthHtml(String htmlText) {
    final a = RegExp(r'var pwdDefaultEncryptSalt = "(.*?)";');
    final matchResult = a.firstMatch(htmlText)!.group(0)!;
    final salt = matchResult.substring(29, matchResult.length - 2);
    debugPrint('Salt: $salt');
    return salt;
  }

  /// Extract the CAS ticket from the auth page
  String _extractCasTicketFromAuthHtml(String htmlText) {
    final a = RegExp(r'<input type="hidden" name="lt" value="(.*?)"');
    final matchResult = a.firstMatch(htmlText)!.group(0)!;
    final casTicket = matchResult.substring(38, matchResult.length - 1);
    debugPrint('CAS Ticket: $casTicket');
    return casTicket;
  }

  /// Fetch the auth page, where the account, password and captcha box are.
  Future<String> _fetchAuthServerHtml() async {
    final response = await _dio.get(
      _loginUrl,
      options: Options(headers: Map.from(_neededHeaders)..remove('Referer')),
    );
    return response.data;
  }

  /// check if captcha is required for this logging in
  Future<bool> isCaptchaRequired(String username) async {
    final response = await _dio.get(
      _needCaptchaUrl,
      queryParameters: {
        'username': username,
        'pwdEncrypt2': 'pwdEncryptSalt',
      },
      options: Options(headers: _neededHeaders),
    );
    final needCaptcha = response.data == 'true';
    debugPrint('Account: $username, Captcha required: $needCaptcha');
    return needCaptcha;
  }

  Future<Uint8List> getCaptcha() async {
    final response = await _dio.get(
      _captchaUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: _neededHeaders,
      ),
    );
    Uint8List captchaData = response.data;
    return captchaData;
  }

  /// Login the single sign-on
  Future<Response> _postLoginRequest(String username, String hashedPassword, String captcha, String casTicket) async {
    // Login
    final res = await _dio.post(
      _loginUrl,
      data: {
        'username': username,
        'password': hashedPassword,
        'captchaResponse': captcha,
        'lt': casTicket,
        'dllt': 'userNamePasswordLogin',
        'execution': 'e1s1',
        '_eventId': 'submit',
        'rmShown': '1',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        followRedirects: false,
        validateStatus: (status) {
          return status! < 400;
        },
        headers: _neededHeaders,
      ),
    );
    final debugDepths = <Response>[];
    final finalResponse = await _dio.processRedirect(
      res,
      headers: _neededHeaders,
      history: debugDepths,
    );
    return finalResponse;
  }

  Future<Response> request(
    String url, {
    Map<String, String>? queryParameters,
    dynamic Function()? data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    networkLogger.i("$SsoSession.request ${DateTime.now().toIso8601String()}");
    return await _ssoLock.run<Response>(() async {
      networkLogger.i("$SsoSession.request-locked ${DateTime.now().toIso8601String()}");
      final res = await _request(
        url,
        queryParameters: queryParameters,
        data: data,
        options: options,
      );
      return res;
    });
  }
}

String _hashPassword(String salt, String password) {
  var iv = _rds(16);
  var encrypt = _SsoEncryption(salt, iv);
  return encrypt.aesEncrypt(_rds(64) + password);
}

final _rand = Random.secure();

String _rds(int num) {
  const chars = 'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678';
  final s = StringBuffer();
  for (var i = 0; i < num; i++) {
    s.write(chars[_rand.nextInt(chars.length)]);
  }
  return s.toString();
}

class _SsoEncryption {
  Key? _key;
  IV? _iv;

  _SsoEncryption(String key, String iv) {
    _key = Key.fromUtf8(key);
    _iv = IV.fromUtf8(iv);
  }

  String aesEncrypt(String content) {
    return Encrypter(
      AES(
        _key!,
        mode: AESMode.cbc,
        padding: 'PKCS7',
      ),
    )
        .encrypt(
          content,
          iv: _iv,
        )
        .base64;
  }
}
