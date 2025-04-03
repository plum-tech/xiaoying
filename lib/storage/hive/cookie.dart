import 'package:flutter/foundation.dart';
import 'package:mimir/r.dart';
import 'package:mimir/utils/hive.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:hive/hive.dart';

class HiveCookieJar implements Storage {
  final Box box;

  const HiveCookieJar(this.box);

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {
    if (R.debugNetwork) {
      debugPrint("[$HiveCookieJar] persistSession=$persistSession, ignoreExpires=$ignoreExpires");
    }
  }

  @override
  Future<void> write(String key, String value) async {
    if (R.debugNetwork) {
      debugPrint("[$HiveCookieJar] Writing cookie: $key=$value.");
    }
    await box.safePut<String>(key, value);
  }

  @override
  Future<String?> read(String key) async {
    if (R.debugNetwork) {
      debugPrint("[$HiveCookieJar] Reading cookie: $key.");
    }
    final value = box.safeGet<String?>(key);
    if (R.debugNetwork) {
      debugPrint("[$HiveCookieJar] Read cookie: $key=$value.");
    }
    return value;
  }

  @override
  Future<void> delete(String key) async {
    if (R.debugNetwork) {
      debugPrint("[$HiveCookieJar] Deleting cookie: $key.");
    }
    await box.delete(key);
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    if (R.debugNetwork) {
      debugPrint("[$HiveCookieJar] Deleting all cookies: $keys.");
    }
    await box.deleteAll(keys);
  }
}
