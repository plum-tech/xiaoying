import 'package:mimir/credentials/entity/user_type.dart';

/// 本、专科生（10位学号）
final _undergraduateId = RegExp(r'^(\d{6}[YGHE\d]\d{3})$');

/// 研究生（9位学号）
final _postgraduateId = RegExp(r'^(\d{2}6\d{6})$');

/// 教师（4位工号）
final _teacherId = RegExp(r'^(\d{4})$');

/// 新生（14位纯数字高考报名号）
final _freshmanId = RegExp(r'^(\d{14})$');

/// [schoolId] can be a student ID or a work number.
OaUserType? estimateOaUserType(String schoolId) {
  if (schoolId.length == 10 && _undergraduateId.hasMatch(schoolId.toUpperCase())) {
    return OaUserType.undergraduate;
  } else if (schoolId.length == 9 && _postgraduateId.hasMatch(schoolId)) {
    return OaUserType.postgraduate;
  } else if (schoolId.length == 4 && _teacherId.hasMatch(schoolId)) {
    return OaUserType.worker;
  } else if (schoolId.length == 14 && _freshmanId.hasMatch(schoolId)) {
    return OaUserType.freshman;
  }
  return null;
}
