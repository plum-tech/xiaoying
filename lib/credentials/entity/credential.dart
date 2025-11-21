import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:mimir/storage/hive/type_id.dart';

part 'credential.g.dart';

@HiveType(typeId: CoreHiveType.credentials)
@CopyWith(skipFields: true)
class Credential {
  @HiveField(0)
  final String account;
  @HiveField(1)
  final String password;

  const Credential({
    required this.account,
    required this.password,
  });

  @override
  String toString() => 'account:"$account", password:"$password"';

  @override
  bool operator ==(Object other) {
    return other is Credential &&
        runtimeType == other.runtimeType &&
        account == other.account &&
        password == other.password;
  }

  @override
  int get hashCode => Object.hash(account, password);
}
