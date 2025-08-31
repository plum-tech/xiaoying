import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mimir/init.dart';

import 'package:mimir/school/entity/school.dart';
import 'package:mimir/session/ug_registration.dart';
import 'package:mimir/settings/settings.dart';

import '../entity/timetable.dart';
import '../utils/parse.ug.dart';

class TimetableService {
  static const _undergraduateTimetableUrl = 'http://jwxt.sit.edu.cn/jwglxt/kbcx/xskbcx_cxXsgrkb.html';

  UgRegistrationSession get _ugRegSession => Init.ugRegSession;

  const TimetableService();

  Future<bool> checkConnectivity() {
    return _ugRegSession.checkConnectivity();
  }

  /// 获取本科生课表
  Future<Timetable> fetchUgTimetable(SemesterInfo info) async {
    final response = await _ugRegSession.request(
      _undergraduateTimetableUrl,
      options: Options(
        method: "POST",
      ),
      queryParameters: {'gnmkdm': 'N253508'},
      data: () => FormData.fromMap({
        // 学年名
        'xnm': info.exactYear.toString(),
        // 学期名
        'xqm': info.semester.toUgRegFormField()
      }),
    );
    final json = response.data;
    return parseUndergraduateTimetableFromRaw(
      json,
      defaultCampus: Settings.campus,
    );
  }

  Future<({DateTime start, DateTime end})?> getUgSemesterSpan() async {
    final res = await _ugRegSession.request(
      "http://jwxt.sit.edu.cn/jwglxt/xtgl/index_cxAreaFive.html",
      options: Options(
        method: "POST",
      ),
    );
    return _parseSemesterSpan(res.data);
  }

  static final _semesterSpanRe = RegExp(r"\((\S+)至(\S+)\)");
  static final _semesterSpanDateFormat = DateFormat("yyyy-MM-dd");

  ({DateTime start, DateTime end})? _parseSemesterSpan(String content) {
    final html = BeautifulSoup(content);
    final element = html.find("th", attrs: {"style": "text-align: center"});
    if (element == null) return null;
    final text = element.text;
    final match = _semesterSpanRe.firstMatch(text);
    if (match == null) return null;
    final start = _semesterSpanDateFormat.tryParse(match.group(1) ?? "");
    final end = _semesterSpanDateFormat.tryParse(match.group(2) ?? "");
    if (start == null || end == null) return null;
    return (start: DateTime(start.year, start.month, start.day), end: DateTime(end.year, end.month, end.day));
  }
}
