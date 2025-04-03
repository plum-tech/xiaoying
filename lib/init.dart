import 'package:flutter/material.dart';
import 'package:mimir/credentials/entity/credential.dart';
import 'package:mimir/credentials/entity/login_status.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/design/adaptive/editor.dart';
import 'package:mimir/entity/campus.dart';

import 'package:flutter/foundation.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/lifecycle.dart';
import 'package:mimir/session/freshman.dart';
import 'package:mimir/storage/hive/init.dart';
import 'package:mimir/session/pg_registration.dart';
import 'package:mimir/session/ywb.dart';
import 'package:mimir/school/electricity/init.dart';
import 'package:mimir/school/expense_records/init.dart';
import 'package:mimir/login/init.dart';
import 'package:mimir/school/ywb/init.dart';
import 'package:mimir/school/exam_arrange/init.dart';
import 'package:mimir/school/oa_announce/init.dart';
import 'package:mimir/school/exam_result/init.dart';
import 'package:mimir/session/ug_registration.dart';
import 'package:mimir/timetable/init.dart';
import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:mimir/storage/hive/cookie.dart';
import 'package:mimir/network/dio.dart';
import 'package:mimir/session/sso.dart';

import '../widget/captcha_box.dart';

class Init {
  const Init._();

  static late CookieJar schoolCookieJar;
  static late CookieJar cookieJar;
  static late Dio schoolDio;
  static late Dio mimirDio;
  static late Dio dioNoCookie;
  static late SsoSession ssoSession;
  static late FreshmanSession freshmanSession;
  static late UgRegistrationSession ugRegSession;
  static late PgRegistrationSession pgRegSession;
  static late YwbSession ywbSession;

  static Future<void> initNetwork() async {
    debugPrint("Initializing network");
    if (kIsWeb) {
      schoolCookieJar = WebCookieJar();
      cookieJar = WebCookieJar();
    } else {
      schoolCookieJar = PersistCookieJar(
        storage: HiveCookieJar(HiveInit.schoolCookies),
      );
      cookieJar = PersistCookieJar(
        storage: HiveCookieJar(HiveInit.cookies),
      );
    }
    final uaForSchoolServer = await getUserAgentForSchoolServer();
    schoolDio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 16 * 1000),
      receiveTimeout: const Duration(milliseconds: 16 * 1000),
      sendTimeout: const Duration(milliseconds: 16 * 1000),
      headers: {
        "User-Agent": uaForSchoolServer,
      },
      validateStatus: (status) => status! < 400,
    )).withCookieJar(schoolCookieJar).withDebugging();

    dioNoCookie = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 16000),
      receiveTimeout: const Duration(milliseconds: 16000),
      sendTimeout: const Duration(milliseconds: 16000),
      headers: {
        "User-Agent": uaForSchoolServer,
      },
      validateStatus: (status) => status! < 400,
    )).withDebugging();

    mimirDio = Dio(BaseOptions()).withCookieJar(cookieJar).withDebugging();

    ssoSession = SsoSession(
      inputCaptcha: _inputCaptcha,
    );
    ugRegSession = const UgRegistrationSession();
    ywbSession = YwbSession(
      dio: schoolDio,
    );
    freshmanSession = const FreshmanSession();
    pgRegSession = PgRegistrationSession(
      ssoSession: ssoSession,
    );
  }

  static Future<void> initModules() async {
    debugPrint("Initializing modules");
    CredentialsInit.init();
    TimetableInit.init();
    if (!kIsWeb) {
      OaAnnounceInit.init();
      ExamResultInit.init();
      ExamArrangeInit.init();
      ExpenseRecordsInit.init();
      YwbInit.init();
      ElectricityBalanceInit.init();
    }
    LoginInit.init();
  }

  static Future<void> initStorage() async {
    debugPrint("Initializing module storage");
    CredentialsInit.initStorage();
    TimetableInit.initStorage();
    if (!kIsWeb) {
      OaAnnounceInit.initStorage();
      ExamResultInit.initStorage();
      ExamArrangeInit.initStorage();
      ExpenseRecordsInit.initStorage();
      YwbInit.initStorage();
      ElectricityBalanceInit.initStorage();
    }
    LoginInit.initStorage();
  }

  static void registerCustomEditor() {
    EditorEx.registerEnumEditor(Campus.values);
    EditorEx.registerEnumEditor(ThemeMode.values);
    Editor.registerEditor<Credential>((ctx, desc, initial) => StringsEditor(
          fields: [
            (name: "account", initial: initial.account),
            (name: "password", initial: initial.password),
          ],
          title: desc,
          ctor: (values) => Credential(account: values[0], password: values[1]),
        ));
    EditorEx.registerEnumEditor(OaLoginStatus.values);
    EditorEx.registerEnumEditor(OaUserType.values);
  }
}

Future<String?> _inputCaptcha(Uint8List imageBytes) async {
  final context = $key.currentContext!;
// return await context.show$Sheet$(
//   (ctx) => CaptchaSheetPage(
//     captchaData: imageBytes,
//   ),
// );
  return await showAdaptiveDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CaptchaDialog(captchaData: imageBytes),
  );
}
