enum AgreementType {
  basic,
  account;

  String get markdownText =>
      "我已阅读并同意 [《小应生活隐私政策》](https://www.xiaoying.life/privacy-policy) 和 [《小应生活使用协议》](https://www.xiaoying.life/terms-of-service)";
}

enum AgreementVersion {
  v20240915("20240915"),
  v20241118("20241118"),
  v20250827("20250827");

  static const current = v20250827;

  final String number;

  const AgreementVersion(this.number);
}
