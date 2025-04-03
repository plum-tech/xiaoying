import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mimir/init.dart';
import 'package:mimir/session/ywb.dart';
import '../entity/balance.dart';

const _balanceUrl = "${YwbSession.base}/unifri-flow/WF/Comm/ProcessRequest.do?DoType=DBAccess_RunSQLReturnTable";

class ElectricityService {
  Dio get _dio => Init.schoolDio;

  const ElectricityService();

  Future<ElectricityBalance> getBalance(String room) async {
    final response = await _dio.post(
      _balanceUrl,
      queryParameters: {
        "SQL": "select * from sys_room_balance where RoomName='$room';",
      },
      options: Options(
        headers: {
          "Cookie": "FK_Dept=B1101",
        },
      ),
    );
    final data = jsonDecode(response.data as String) as List;
    final list = data.map((e) => ElectricityBalance.fromJson(e)).toList();
    return list.first;
  }
}
