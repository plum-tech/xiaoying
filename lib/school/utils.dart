import 'package:mimir/l10n/time.dart';
import 'package:mimir/school/entity/school.dart';

/// 将 "第几周、周几" 转换为日期. 如, 开学日期为 2021-9-1, 那么将第一周周一转换为 2021-9-1
DateTime reflectWeekDayIndexToDate({
  required DateTime startDate,
  required int weekIndex,
  required Weekday weekday,
}) {
  return startDate.add(Duration(days: weekIndex * 7 + weekday.index));
}

final _parenthesesRegx = RegExp(r"\((.*?)\)");

/// Exchange a string in brackets with a string out of brackets,
/// if the string in brackets has a substring such as "一教", "二教", and "三教".
String reformatPlace(String place) {
  final matched = _parenthesesRegx.firstMatch(place);
  if (matched == null) return place;
  final inParentheses = matched.group(1);
  if (inParentheses == null) return place;
  if (!inParentheses.contains("一教") && !inParentheses.contains("二教") && !inParentheses.contains("三教")) return place;
  final outParentheses = place.replaceRange(matched.start, matched.end, "");
  return "$inParentheses($outParentheses)";
}

/// 删去 place 括号里的描述信息. 如, 二教F301（机电18中外合作专用）
/// But it will keep the "三教" in brackets.
String beautifyPlace(String place) {
  int indexOfBucket = place.indexOf('(');
  return indexOfBucket != -1 ? place.substring(0, indexOfBucket) : place;
}

/// Replace the full-width brackets to ASCII ones
String mapChinesePunctuations(String name) {
  final b = StringBuffer();
  for (final c in name.runes) {
    switch (c) {
      case 0xFF08: // （
        b.writeCharCode(0x28); // (
        break;

      case 0xFF09: // ）
        b.writeCharCode(0x29); // )
        break;

      case 0x3010: // 【
        b.writeCharCode(0x5B); // [
        break;

      case 0x3011: // 】
        b.writeCharCode(0x5D); // ]
        break;

      case 0xFF06: // ＆
        b.writeCharCode(0x26); // &
        break;
      default:
        b.writeCharCode(c);
    }
  }
  return b.toString();
}

int? getAdmissionYearFromStudentId(String? studentId) {
  if (studentId == null) return null;
  if (studentId.length < 2) return null;
  final fromID = int.tryParse(studentId.substring(0, 2));
  if (fromID == null) return null;
  return 2000 + fromID;
}

SemesterInfo estimateSemesterInfo([DateTime? date]) {
  date ??= DateTime.now();
  return SemesterInfo(
    year: estimateSchoolYear(date),
    semester: estimateSemester(date),
  );
}

int estimateSchoolYear([DateTime? date]) {
  date ??= DateTime.now();
  final month = date.month;
  return month >= 9 ? date.year : date.year - 1;
}

Semester estimateSemester([DateTime? date]) {
  date ??= DateTime.now();
  final month = date.month;
  return 3 <= month && month <= 7 ? Semester.term2 : Semester.term1;
}

final _tagParenthesesRegx = RegExp(r"\[(.*?)\]");

({String title, List<String> tags}) separateTagsFromTitle(String full) {
  if (full.isEmpty) return (title: "", tags: <String>[]);
  final allMatched = _tagParenthesesRegx.allMatches(full);
  final resultTags = <String>[];
  for (final matched in allMatched) {
    final tag = matched.group(1);
    if (tag != null) {
      final tags = tag.split("&");
      for (final tag in tags) {
        resultTags.add(tag.trim());
      }
    }
  }
  final title = full.replaceAll(_tagParenthesesRegx, "");
  return (title: title, tags: resultTags.toSet().toList());
}
