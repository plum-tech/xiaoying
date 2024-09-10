import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/credentials/entity/credential.dart';
import 'package:mimir/credentials/entity/login_status.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/credentials/utils.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/animation/animated.dart';
import 'package:mimir/init.dart';
import 'package:mimir/l10n/common.dart';
import 'package:mimir/login/utils.dart';
import 'package:mimir/r.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/school/widgets/campus.dart';
import 'package:mimir/widgets/markdown.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/settings/dev.dart';
import 'package:mimir/settings/meta.dart';
import 'package:mimir/settings/settings.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart' hide isCupertino;

import '../i18n.dart';
import '../widgets/forgot_pwd.dart';
import '../x.dart';

const _i18n = _I18n();

class _I18n extends OaLoginI18n {
  const _I18n();

  final network = const NetworkI18n();
}

const oaForgotLoginPasswordUrl =
    "https://authserver.sit.edu.cn/authserver/getBackPasswordMainPage.do?service=https%3A%2F%2Fmyportal.sit.edu.cn%3A443%2F";

class LoginPage extends ConsumerStatefulWidget {
  final bool isGuarded;

  const LoginPage({super.key, required this.isGuarded});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final $account = TextEditingController(text: Dev.demoMode ? R.demoModeOaCredentials.account : null);
  final $password = TextEditingController(text: Dev.demoMode ? R.demoModeOaCredentials.password : null);
  final _formKey = GlobalKey<FormState>();
  bool isPasswordClear = false;
  bool loggingIn = false;
  OaUserType? estimatedUserType;
  int? admissionYear;
  // bool? schoolServerConnected;

  @override
  void initState() {
    super.initState();
    $account.addListener(onAccountChange);
    // checkSchoolServerConnectivity();
  }

  @override
  void dispose() {
    $account.dispose();
    $password.dispose();
    super.dispose();
  }

  // Future<void> checkSchoolServerConnectivity() async {
  //   final connected = await Init.ssoSession.checkConnectivity();
  //   if (!mounted) return;
  //   setState(() {
  //     schoolServerConnected = connected;
  //   });
  // }

  void onAccountChange() {
    var account = $account.text;
    account = account.toUpperCase();
    if (account != $account.text) {
      $account.text = account;
    }
    setState(() {
      estimatedUserType = estimateOaUserType(account);
      admissionYear = getAdmissionYearFromStudentId(account);
    });
  }

  /// 用户点击登录按钮后
  Future<void> login() async {
    final account = $account.text;
    final password = $password.text;
    if (account == R.demoModeOaCredentials.account && password == R.demoModeOaCredentials.password) {
      await loginDemoMode();
    } else {
      await loginWithCredentials(account, password, formatValid: (_formKey.currentState as FormState).validate());
    }
  }

  Future<void> loginDemoMode() async {
    if (!mounted) return;
    setState(() => loggingIn = true);
    final rand = Random();
    await Future.delayed(Duration(milliseconds: rand.nextInt(2000)));
    Meta.userRealName = "Liplum";
    Settings.lastSignature ??= "Liplum";
    CredentialsInit.storage.oa.credentials = R.demoModeOaCredentials;
    CredentialsInit.storage.oa.loginStatus = OaLoginStatus.validated;
    CredentialsInit.storage.oa.lastAuthTime = DateTime.now();
    CredentialsInit.storage.oa.userType = OaUserType.undergraduate;
    Dev.demoMode = true;
    await Init.initModules();
    if (!mounted) return;
    setState(() => loggingIn = false);
    context.go("/");
  }

  /// After the user clicks the login button
  Future<void> loginWithCredentials(
    String account,
    String password, {
    required bool formatValid,
  }) async {
    final userType = estimateOaUserType(account);
    if (!formatValid || userType == null || account.isEmpty || password.isEmpty) {
      await context.showTip(
        title: _i18n.formatError,
        desc: _i18n.validateInputAccountPwdRequest,
        primary: _i18n.close,
        serious: true,
      );
      return;
    }

    if (!mounted) return;
    setState(() => loggingIn = true);
    final connectionType = await Connectivity().checkConnectivity();
    if (connectionType.contains(ConnectivityResult.none)) {
      if (!mounted) return;
      setState(() => loggingIn = false);
      await context.showTip(
        title: _i18n.network.error,
        desc: _i18n.network.noAccessTip,
        primary: _i18n.close,
        serious: true,
      );
      return;
    }

    try {
      await XLogin.login(Credentials(account: account, password: password));
      if (!mounted) return;
      setState(() => loggingIn = false);
      context.go("/");
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() => loggingIn = false);
      if (error is Exception) {
        await handleLoginException(context: context, error: error, stackTrace: stackTrace);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(CredentialsInit.storage.oa.$credentials, (pre, next) {
      if (next != null) {
        $account.text = next.account;
        $password.text = next.password;
      }
    });

    return GestureDetector(
      onTap: () {
        // dismiss the keyboard when tap out of TextField.
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: buildBody(),
    );
  }

  Widget buildBody() {
    if (context.isPortrait) {
      return Scaffold(
        appBar: AppBar(
          title: widget.isGuarded ? _i18n.loginRequired.text() : const CampusSelector(),
          actions: [
            buildSettingsAction(),
          ],
        ),
        floatingActionButton: loggingIn ? const CircularProgressIndicator.adaptive() : null,
        body: [
          buildHeader(),
          buildLoginForm(),
          const Divider(),
          const OaLoginDisclaimerCard(),
          AnimatedShowUp(
            when: estimatedUserType == OaUserType.freshman && admissionYear == DateTime.now().year,
            builder: (ctx) => const OaLoginFreshmanSystemTipCard(),
          ),
          AnimatedShowUp(
            when: estimatedUserType == OaUserType.undergraduate && admissionYear == DateTime.now().year,
            builder: (ctx) => const OaLoginFreshmanTipCard(),
          ),
          buildLoginButton(),
          const ForgotPasswordButton(url: oaForgotLoginPasswordUrl),
        ].column(mas: MainAxisSize.min).scrolled(physics: const NeverScrollableScrollPhysics()).padH(25).center(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: widget.isGuarded ? _i18n.loginRequired.text() : _i18n.welcomeHeader.text(),
          actions: [
            buildSettingsAction(),
          ],
        ),
        floatingActionButton: loggingIn ? const CircularProgressIndicator.adaptive() : null,
        body: [
          [
            const CampusSelector(),
            const OaLoginDisclaimerCard(),
            AnimatedShowUp(
              when: estimatedUserType == OaUserType.freshman && admissionYear == DateTime.now().year,
              builder: (ctx) => const OaLoginFreshmanSystemTipCard(),
            ),
            AnimatedShowUp(
              when: estimatedUserType == OaUserType.undergraduate && admissionYear == DateTime.now().year,
              builder: (ctx) => const OaLoginFreshmanTipCard(),
            ),
          ].column(maa: MainAxisAlignment.start).scrolled().expanded(),
          const VerticalDivider(),
          [
            buildLoginForm(),
            buildLoginButton(),
            const ForgotPasswordButton(url: oaForgotLoginPasswordUrl),
          ].column().scrolled().expanded(),
        ].row(),
      );
    }
  }

  Widget buildSettingsAction() {
    return PlatformIconButton(
      icon: isCupertino ? const Icon(CupertinoIcons.settings) : const Icon(Icons.settings),
      onPressed: () {
        context.push("/settings");
      },
    );
  }

  // Widget buildConnectivityIcon() {
  //   return switch (schoolServerConnected) {
  //     null => const CircularProgressIndicator.adaptive(),
  //     true =>  const Icon(Icons.check),
  //     false => const Icon(Icons.public_off),
  //   };
  // }

  Widget buildHeader() {
    return widget.isGuarded
        ? const Icon(
            Icons.person_off_outlined,
            size: 120,
          )
        : _i18n.welcomeHeader
            .text(
              style: context.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
            .padSymmetric(v: 20);
  }

  Widget buildLoginForm() {
    return Form(
      autovalidateMode: AutovalidateMode.always,
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          children: [
            TextFormField(
              controller: $account,
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
              autocorrect: false,
              autofocus: true,
              readOnly: loggingIn,
              enableSuggestions: false,
              validator: (account) => studentIdValidator(account, () => _i18n.invalidAccountFormat),
              decoration: InputDecoration(
                labelText: _i18n.credentials.account,
                hintText: _i18n.accountHint,
                icon: Icon(context.icons.person),
              ),
            ),
            TextFormField(
              controller: $password,
              keyboardType: isPasswordClear ? TextInputType.visiblePassword : null,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.send,
              readOnly: loggingIn,
              contextMenuBuilder: (ctx, state) {
                return AdaptiveTextSelectionToolbar.editableText(
                  editableTextState: state,
                );
              },
              autocorrect: false,
              autofocus: true,
              enableSuggestions: false,
              obscureText: !isPasswordClear,
              onFieldSubmitted: (inputted) async {
                await login();
              },
              decoration: InputDecoration(
                labelText: estimatedUserType == OaUserType.freshman ? "迎新系统密码" : _i18n.credentials.oaPwd,
                hintText: estimatedUserType == OaUserType.freshman ? "请输入迎新系统密码" : _i18n.oaPwdHint,
                icon: Icon(context.icons.lock),
                suffixIcon: PlatformIconButton(
                  icon: Icon(isPasswordClear ? context.icons.eyeSolid : context.icons.eyeSlashSolid),
                  onPressed: () {
                    setState(() {
                      isPasswordClear = !isPasswordClear;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoginButton() {
    return [
      $account >>
          (ctx, account) => FilledButton.icon(
                // Online
                onPressed: !loggingIn && account.text.isNotEmpty
                    ? () {
                        // un-focus the text field.
                        FocusScope.of(context).requestFocus(FocusNode());
                        login();
                      }
                    : null,
                icon: const Icon(Icons.login),
                label: _i18n.login.text(),
              ),
      if (!widget.isGuarded)
        $account >>
            (ctx, account) =>
                $password >>
                (ctx, password) => OutlinedButton(
                      // Offline
                      onPressed: account.text.isNotEmpty || password.text.isNotEmpty
                          ? null
                          : () {
                              CredentialsInit.storage.oa.loginStatus = OaLoginStatus.offline;
                              context.go("/");
                            },
                      child: _i18n.offlineModeBtn.text(),
                    ),
    ].row(caa: CrossAxisAlignment.center, maa: MainAxisAlignment.spaceAround);
  }
}

/// Only allow student ID/ work number.
String? studentIdValidator(String? account, String Function() invalidMessage) {
  if (account != null && account.isNotEmpty) {
    if (estimateOaUserType(account) == null) {
      return invalidMessage();
    }
  }
  return null;
}

class OaLoginDisclaimerCard extends StatelessWidget {
  const OaLoginDisclaimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      FeaturedMarkdownWidget(
        data: _disclaimer,
      ),
    ].column(caa: CrossAxisAlignment.stretch).padAll(12).inOutlinedCard();
  }
}

const _disclaimer = """
您即将登录上海应用技术大学（简称"学校"）的[信息门户（简称"OA"）](https://myportal.sit.edu.cn/)的账户，
作为学校其他系统的统一认证服务。

我们非常重视您的隐私安全。您的账号与密码仅用于提交给学校服务器进行身份验证，并仅存储在本地。
""";

class OaLoginFreshmanSystemTipCard extends StatelessWidget {
  const OaLoginFreshmanSystemTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      FeaturedMarkdownWidget(
        data: _freshmanSystemTip,
      ),
    ].column(caa: CrossAxisAlignment.stretch).padAll(12).inOutlinedCard();
  }
}

const _freshmanSystemTip = """
您即将使用高考报名号登录迎新系统，仅可查看您的入学信息，
如学院专业、宿舍房间号，和辅导员及其联系方式。
请查看《新生入学须知》以了解初始密码。

迎新系统不与其他系统共通（如课程表功能），在您入学后，请使用学校为您分配的学号重新登录。
""";

class OaLoginFreshmanTipCard extends StatelessWidget {
  const OaLoginFreshmanTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      FeaturedMarkdownWidget(
        data: _freshmanTip,
      ),
    ].column(caa: CrossAxisAlignment.stretch).padAll(12).inOutlinedCard();
  }
}

const _freshmanTip = """
OA账户与迎新系统间独立且不共通，请勿使用高考报名号作为账号。请查看《新生入学须知》以了解初始密码。

在首次登录前，可能还需前往[OA官网](https://myportal.sit.edu.cn/)修改初始密码并绑定手机号。
""";
