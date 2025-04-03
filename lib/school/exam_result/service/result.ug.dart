import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:mimir/design/animation/progress.dart';
import 'package:mimir/init.dart';

import 'package:mimir/school/entity/school.dart';
import 'package:mimir/session/ug_registration.dart';

import '../entity/result.ug.dart';

class ExamResultUgService {
  static const _scoreUrl = 'http://jwxt.sit.edu.cn/jwglxt/cjcx/cjcx_cxDgXscj.html';
  static const _scoreDetailsUrl = 'http://jwxt.sit.edu.cn/jwglxt/cjcx/cjcx_cxCjxqGjh.html';

  /* Why there child is 1,3,5 not 1,2,3?
    The example likes follow:
          <tr>
              <td valign="middle">【 平时 】</td>
              <td valign="middle">40%&nbsp;</td>
              <td valign="middle">77.5&nbsp;</td>
          </tr>
    When you use 1,2,3 to choose the <td>, you will get [] by 2,
    it's because /n is chosen by 2 in dart,so here use 1,3,5 to choose <td>
  */
  static const _scoreDetailPageSelector = 'div.table-responsive > #subtab > tbody > tr';
  static const _scoreFormSelector = 'td:nth-child(1)';
  static const _scorePercentageSelector = 'td:nth-child(3)';
  static const _scoreValueSelector = 'td:nth-child(5)';

  UgRegistrationSession get _session => Init.ugRegSession;

  const ExamResultUgService();

  /// 获取成绩
  Future<List<ExamResultUg>> fetchResultList(
    SemesterInfo info, {
    void Function(double progress)? onProgress,
  }) async {
    final year = info.year;
    final progress = ProgressWatcher(callback: onProgress);
    final response = await _session.request(
      _scoreUrl,
      options: Options(
        method: "POST",
      ),
      queryParameters: {
        'gnmkdm': 'N305005',
        'doType': 'query',
      },
      data: () => FormData.fromMap({
        // 学年名
        'xnm': year == null ? "" : year.toString(),
        // 学期名
        'xqm': info.semester.toUgRegFormField(),
        // 获取成绩最大数量
        'queryModel.showCount': 5000,
      }),
    );
    progress.value = 0.2;
    final resultList = _parseScoreList(response.data);
    final perProgress = resultList.isEmpty ? 0 : 0.8 / resultList.length;
    final newResultList = await Future.wait(resultList.map((result) async {
      final resultItems = await _fetchResultItems(
        info: result.semesterInfo,
        classId: result.innerClassId,
      );
      progress.value += perProgress;
      return result.copyWith(items: resultItems);
    }));
    progress.value = 1;
    return newResultList;
  }

  static List<ExamResultUg> _parseScoreList(Map<String, dynamic> json) {
    final List? scoreList = json['items'];
    if (scoreList == null) return const [];
    return scoreList.map((e) => ExamResultUg.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 获取成绩详情
  Future<List<ExamResultItem>> _fetchResultItems({
    required SemesterInfo info,
    required String classId,
  }) async {
    final response = await _session.request(
      _scoreDetailsUrl,
      options: Options(
        method: "POST",
      ),
      queryParameters: {'gnmkdm': 'N305005'},
      data: () => FormData.fromMap({
        // 班级
        'jxb_id': classId,
        // 学年名
        'xnm': info.year.toString(),
        // 学期名
        'xqm': info.semester.toUgRegFormField()
      }),
    );
    final html = response.data as String;
    return _parseDetailsPage(html);
  }

  static List<ExamResultItem> _parseDetailsPage(String htmlPage) {
    final BeautifulSoup soup = BeautifulSoup(htmlPage);
    final elements = soup.findAll(_scoreDetailPageSelector);

    return elements.map(_mapToDetailsItem).toList();
  }

  static ExamResultItem _mapToDetailsItem(Bs4Element item) {
    f1(s) => s.replaceAll('&nbsp;', '').replaceAll(' ', '');
    f2(s) => s.replaceAll('【', '').replaceAll('】', '');
    f(s) => f1(f2(s));

    String type = item.find(_scoreFormSelector)!.innerHtml.trim();
    String percentage = item.find(_scorePercentageSelector)!.innerHtml.trim();
    String value = item.find(_scoreValueSelector)!.innerHtml;

    return ExamResultItem(
      scoreType: f(type),
      percentage: f(percentage),
      score: double.tryParse(f(value)),
    );
  }
}
