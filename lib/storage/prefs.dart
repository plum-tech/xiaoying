import 'package:shared_preferences/shared_preferences.dart';
import 'package:mimir/r.dart';

class _K {
  static const lastVersion = "${R.appId}.lastVersion";
  static const installTime = "${R.appId}.installTime";
  static const uuid = "${R.appId}.uuid";
}

extension PrefsX on SharedPreferences {
  String? getLastVersion() => getString(_K.lastVersion);

  Future<void> setLastVersion(String value) => setString(_K.lastVersion, value);

  /// The first time when user launch this app
  DateTime? getInstallTime() {
    final raw = getString(_K.installTime);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setInstallTime(DateTime value) => setString(_K.installTime, value.toString());

  String? getUuid() => getString(_K.uuid);

  Future<void> setUuid(String value) => setString(_K.uuid, value);
}
