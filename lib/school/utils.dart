import 'package:mimir/school/entity/school.dart';
import 'package:mimir/utils/weekday.dart';

/// 将 "第几周、周几" 转换为日期. 如, 开学日期为 2021-9-1, 那么将第一周周一转换为 2021-9-1
DateTime reflectWeekDayIndexToDate({
  required DateTime startDate,
  required int weekIndex,
  required Weekday weekday,
}) {
  return startDate.add(Duration(days: weekIndex * 7 + weekday.index));
}

/// 删去 place 括号里的描述信息. 如, 二教F301（机电18中外合作专用）
/// But it will keep the "三教" in brackets.
String beautifyPlace(String place) {
  int indexOfBucket = place.indexOf('(');
  return indexOfBucket != -1 ? place.substring(0, indexOfBucket) : place;
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
