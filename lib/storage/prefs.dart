import 'package:shared_preferences/shared_preferences.dart';
import 'package:mimir/r.dart';

class _K {
  static const uuid = "${R.appId}.uuid";
}

extension PrefsX on SharedPreferences {
  String? getUuid() => getString(_K.uuid);

  Future<void> setUuid(String value) => setString(_K.uuid, value);
}
