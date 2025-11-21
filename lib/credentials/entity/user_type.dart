import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/storage/hive/type_id.dart';

part 'user_type.g.dart';

@HiveType(typeId: CoreHiveType.oaUserType)
enum OaUserType {
  @HiveField(0)
  undergraduate(),
  @HiveField(1)
  postgraduate(),
  @HiveField(2)
  freshman(),
  @HiveField(3)
  worker(),
  @HiveField(4)
  none();

  const OaUserType();

  String l10n() => "OaUserType.$name".tr();
}
