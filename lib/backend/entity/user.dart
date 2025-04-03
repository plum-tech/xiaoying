import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum SchoolCode {
  sit("10259");

  final String code;

  const SchoolCode(this.code);

  String l10n() => "mimir.school.$code".tr();

  static final code2enum = Map.fromEntries(values.map((v) => MapEntry(v.code, v)));
}
