import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/storage/hive/type_id.dart';

part 'campus.g.dart';

@HiveType(typeId: CoreHiveType.campus)
enum Campus {
  @HiveField(0)
  fengxian(),
  @HiveField(1)
  xuhui();

  const Campus();

  String l10n() => "campus.$name".tr();
}
