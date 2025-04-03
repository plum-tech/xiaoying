import 'package:dio/dio.dart';
import 'package:mimir/init.dart';

import 'package:mimir/session/ug_registration.dart';

import '../entity/exam.dart';
import 'package:mimir/school/entity/school.dart';

class ExamArrangeService {
  static const _examRoomUrl = 'http://jwxt.sit.edu.cn/jwglxt/kwgl/kscx_cxXsksxxIndex.html';

  UgRegistrationSession get _session => Init.ugRegSession;

  const ExamArrangeService();

  /// 获取考场信息
  Future<List<ExamEntry>> fetchExamList(SemesterInfo info) async {
    final response = await _session.request(
      _examRoomUrl,
      queryParameters: {
        'doType': 'query',
        'gnmkdm': 'N358105',
      },
      data: () => FormData.fromMap({
        // 学年名
        'xnm': info.year.toString(),
        // 学期名
        'xqm': info.semester.toUgRegFormField(),
      }),
      options: Options(
        method: "POST",
      ),
    );
    final List<dynamic> itemsData = response.data['items'];
    final list = itemsData.map((e) => ExamEntry.parseRemoteJson(e as Map<String, dynamic>)).toList();
    return list;
  }
}
