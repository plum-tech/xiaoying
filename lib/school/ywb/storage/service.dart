import 'package:hive/hive.dart';
import 'package:mimir/storage/hive/init.dart';
import 'package:mimir/utils/hive.dart';

import '../entity/service.dart';

class _K {
  static const ns = "/meta";
  static const serviceList = "$ns/serviceList";

  static String details(String applicationId) => "$ns/details/$applicationId";
}

class YwbServiceStorage {
  Box get box => HiveInit.ywb;

  const YwbServiceStorage();

  YwbServiceDetails? getServiceDetails(String applicationId) =>
      box.safeGet<YwbServiceDetails>(_K.details(applicationId));

  void setMetaDetails(String applicationId, YwbServiceDetails? newV) =>
      box.safePut<YwbServiceDetails>(_K.details(applicationId), newV);

  List<YwbService>? get serviceList => box.safeGet<List>(_K.serviceList)?.cast<YwbService>();

  set serviceList(List<YwbService>? newV) => box.safePut<List>(_K.serviceList, newV);
}
