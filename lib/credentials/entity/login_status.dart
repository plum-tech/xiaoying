import 'package:mimir/storage/hive/type_id.dart';

part 'login_status.g.dart';

@HiveType(typeId: CoreHiveType.oaLoginStatus)
enum OaLoginStatus {
  @HiveField(0)
  never,
  @HiveField(2)
  offline,
  @HiveField(3)
  validated,
  @HiveField(4)
  everLogin,
}
