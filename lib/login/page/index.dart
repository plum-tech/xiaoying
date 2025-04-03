import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/agreements/entity/agreements.dart';
import 'package:mimir/credentials/entity/credential.dart';
import 'package:mimir/credentials/entity/login_status.dart';
import 'package:mimir/credentials/entity/user_type.dart';
import 'package:mimir/credentials/init.dart';
import 'package:mimir/credentials/utils.dart';
import 'package:mimir/design/adaptive/dialog.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/design/animation/animated.dart';
import 'package:mimir/login/utils.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/school/widget/campus.dart';
import 'package:mimir/agreements/widget/agreements.dart';
import 'package:mimir/widget/markdown.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/settings/settings.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart' hide isCupertino;

import '../i18n.dart';
import '../widget/forgot_pwd.dart';
import '../x.dart';

const _i18n = _I18n();

class _I18n extends OaLoginI18n {
  const _I18n();
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
  final $account = TextEditingController(text: null);
  final $password = TextEditingController(text: null);
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
    final acceptedAgreements = ref.read(Settings.agreements.$basicAcceptanceOf(AgreementVersion.current)) ?? false;
    if (!acceptedAgreements) {
      await showAgreementsRequired2Accept(context);
      return;
    }
    final account = $account.text;
    final password = $password.text;
    await loginWithCredential(account, password, formatValid: (_formKey.currentState as FormState).validate());
  }

  /// After the user clicks the login button
  Future<void> loginWithCredential(
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
    try {
      await XLogin.login(Credential(account: account, password: password));
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
          const SizedBox(height: 10),
          const OaLoginDisclaimerCard(),
          AnimatedShowUp(
            when: estimatedUserType == OaUserType.freshman,
            builder: (ctx) => const OaLoginFreshmanSystemTipCard(),
          ),
          AnimatedShowUp(
            when: estimatedUserType == OaUserType.undergraduate && admissionYear == DateTime.now().year,
            builder: (ctx) => const OaLoginFreshmanTipCard(),
          ),
          buildLoginButton(),
          const ForgotPasswordButton(url: oaForgotLoginPasswordUrl),
        ].column(mas: MainAxisSize.min).scrolled().padH(10).center(),
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
            buildHeader(),
            const CampusSelector(),
            const OaLoginDisclaimerCard(),
            AnimatedShowUp(
              when: estimatedUserType == OaUserType.freshman,
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
        ? const Icon(Icons.person_off_outlined, size: 120)
        : Image.asset("assets/icon.png", width: 80, height: 80);
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
              enableSuggestions: false,
              obscureText: !isPasswordClear,
              onFieldSubmitted: (inputted) async {
                await login();
              },
              decoration: InputDecoration(
                labelText: estimatedUserType == OaUserType.freshman ? _i18n.freshmanSystemPwd : _i18n.credentials.oaPwd,
                hintText: estimatedUserType == OaUserType.freshman ? _i18n.freshmanSystemPwdHint : _i18n.oaPwdHint,
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
    final acceptedAgreements = ref.watch(Settings.agreements.$basicAcceptanceOf(AgreementVersion.current)) ?? false;
    return [
      $account >>
          (ctx, account) => FilledButton.icon(
                // Online
                onPressed: !loggingIn && account.text.isNotEmpty && acceptedAgreements
                    ? () {
                        // un-focus the text field.
                        FocusScope.of(context).requestFocus(FocusNode());
                        login();
                      }
                    : null,
                icon: const Icon(Icons.login),
                label: _i18n.login.text(),
              ),
      if (!widget.isGuarded && ref.watch(CredentialsInit.storage.oa.$lastAuthTime) == null)
        $account >>
            (ctx, account) =>
                $password >>
                (ctx, password) => OutlinedButton(
                      // Offline
                      onPressed: account.text.isEmpty && password.text.isEmpty && acceptedAgreements
                          ? () {
                              CredentialsInit.storage.oa.loginStatus = OaLoginStatus.offline;
                              context.go("/");
                            }
                          : null,
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
        data: _i18n.disclaimer,
      ),
    ].column(caa: CrossAxisAlignment.stretch).padAll(12).inOutlinedCard();
  }
}

class OaLoginFreshmanSystemTipCard extends StatelessWidget {
  const OaLoginFreshmanSystemTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      FeaturedMarkdownWidget(
        data: _i18n.freshmanSystemTip,
      ),
    ].column(caa: CrossAxisAlignment.stretch).padAll(12).inOutlinedCard();
  }
}

class OaLoginFreshmanTipCard extends StatelessWidget {
  const OaLoginFreshmanTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      FeaturedMarkdownWidget(
        data: _i18n.freshmanTip,
      ),
    ].column(caa: CrossAxisAlignment.stretch).padAll(12).inOutlinedCard();
  }
}
