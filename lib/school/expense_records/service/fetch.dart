import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:mimir/init.dart';

import 'package:mimir/session/sso.dart';

import '../entity/local.dart';
import '../entity/remote.dart';
import '../utils.dart';

class ExpenseService {
  String _al2(int v) => v < 10 ? "0$v" : "$v";

  String _format(DateTime d) =>
      "${d.year}${_al2(d.month)}${_al2(d.day)}${_al2(d.hour)}${_al2(d.minute)}${_al2(d.second)}";

  static const String magicNumber = "adc4ac6822fd462780f878b86cb94688";
  static const urlPath = "https://xgfy.sit.edu.cn/yktapi/services/querytransservice/querytrans";

  SsoSession get _session => Init.ssoSession;

  const ExpenseService();

  Future<List<Transaction>> fetch({
    required String studentID,
    required DateTime from,
    required DateTime to,
  }) async {
    final curTs = _format(DateTime.now());
    final fromTs = _format(from);
    final toTs = _format(to);
    final auth = _composeAuth(studentID, fromTs, toTs, curTs);

    final res = await _session.request(
      urlPath,
      options: Options(
        contentType: 'text/plain',
        method: "POST",
      ),
      queryParameters: {
        'timestamp': curTs,
        'starttime': fromTs,
        'endtime': toTs,
        'sign': auth,
        'sign_method': 'HMAC',
        'stuempno': studentID,
      },
    );
    final raw = _parseDataPack(res.data);
    final list = raw.transactions.map(parseFull).toList();
    return list;
  }

  DataPackRaw _parseDataPack(dynamic data) {
    final res = HashMap<String, dynamic>.of(data);
    final retdataRaw = res["retdata"];
    final retdata = json.decode(retdataRaw);
    res["retdata"] = retdata;
    return DataPackRaw.fromJson(res);
  }

  String _composeAuth(String studentId, String from, String to, String cur) {
    final full = studentId + from + to + cur;
    final msg = utf8.encode(full);
    final key = utf8.encode(magicNumber);
    final hmac = Hmac(sha1, key);
    return hmac.convert(msg).toString();
  }
}
