import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:mimir/init.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/session/pg_registration.dart';

import '../entity/result.pg.dart';

class ExamResultPgService {
  static const _postgraduateScoresUrl = "http://gms.sit.edu.cn/epstar/app/template.jsp";

  PgRegistrationSession get _gmsSession => Init.pgRegSession;

  const ExamResultPgService();

  Future<List<ExamResultPgRaw>> fetchResultRawList() async {
    final res = await _gmsSession.request(
      _postgraduateScoresUrl,
      options: Options(
        method: "GET",
      ),
      para: {
        "mainobj": "YJSXT/PYGL/CJGLST/V_PYGL_CJGL_KSCJHZB",
        "tfile": "KSCJHZB_CJCX_CD/KSCJHZB_XSCX_CD_BD",
      },
    );
    final resultRawList = _parse(res.data);
    return resultRawList;
  }

  Future<List<ExamResultPg>> fetchResultList() async {
    final rawList = await fetchResultRawList();
    return rawList.where((raw) => raw.canParse()).map((raw) => raw.parse()).toList();
  }

  static List<ExamResultPgRaw> _parse(String html) {
    List<ExamResultPgRaw> all = [];

    final htmlDocument = parse(html);
    final table = htmlDocument
        .querySelectorAll('table.t_table')[1]
        .querySelector("tbody")!
        .querySelectorAll("tr")[1]
        .querySelector("td");
    final tbody = table!.querySelector("tbody");
    final trList = tbody!.querySelectorAll("tr");
    for (var tr in trList) {
      if (tr.className == "tr_fld_v") {
        final tdList = tr.querySelectorAll("td");
        var courseClass = mapChinesePunctuations(tdList[0].text.trim());
        var courseCode = tdList[1].text.trim();
        var courseName = mapChinesePunctuations(tdList[2].text.trim());
        var courseCredit = tdList[3].text.trim();
        var teacher = tdList[4].text.trim();
        var score = tdList[5].text.trim();
        var isPassed = tdList[6].text.trim();
        var examNature = tdList[7].text.trim();
        var examForm = tdList[8].text.trim();
        var examTime = tdList[9].text.trim();
        var notes = tdList[9].text.trim();
        final scoresRaw = ExamResultPgRaw(
          courseType: courseClass,
          courseCode: courseCode,
          courseName: courseName,
          credit: courseCredit,
          teacher: teacher,
          score: score,
          passStatus: isPassed,
          examType: examNature,
          examForm: examForm,
          examTime: examTime,
          notes: notes,
        );
        all.add(scoresRaw);
      }
    }
    return all;
  }
}
