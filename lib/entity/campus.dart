import 'package:mimir/storage/hive/type_id.dart';

part 'campus.g.dart';

@HiveType(typeId: CoreHiveType.campus)
enum Campus {
  @HiveField(0)
  defaultCampus();

  const Campus();

  String get label => "默认校区";
}
