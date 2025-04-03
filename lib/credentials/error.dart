import 'package:easy_localization/easy_localization.dart';

class CredentialErrorType {
  final String type;

  const CredentialErrorType._(this.type);

  static const //
      accountPassword = CredentialErrorType._("accountPassword"),
      captcha = CredentialErrorType._("captcha"),
      frozen = CredentialErrorType._("frozen"),
      locked = CredentialErrorType._("locked");
  static const //
      oaFrozen = CredentialErrorType._("oa-frozen"),
      oaLocked = CredentialErrorType._("oa-locked"),
      oaIncompleteUserInfo = CredentialErrorType._("oa-incompleteUserInfo");

  String l10n() => "credentials.error.$type".tr();

  @override
  String toString() {
    return type;
  }
}

class CredentialException implements Exception {
  final CredentialErrorType type;
  final String? message;

  const CredentialException({
    required this.type,
    this.message,
  });

  @override
  String toString() {
    final message = this.message;
    if (message == null) return "CredentialsException";
    return "CredentialsException: $type $message";
  }
}
