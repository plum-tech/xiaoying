import 'package:html/parser.dart';
import 'package:mimir/backend/entity/user.dart';
import 'package:mimir/entity/campus.dart';
import 'package:mimir/school/entity/school.dart';
import 'package:mimir/school/exam_result/entity/result.pg.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/timetable/entity/timetable.dart';
import 'package:uuid/uuid.dart';

import '../entity/course.dart';
import 'parse.ug.dart';

Timetable parsePostgraduateTimetableFromRaw({
  required List<ExamResultPgRaw> resultList,
  required String pageHtml,
  required Campus campus,
  required String studentId,
}) {
  final courseList = parsePostgraduateCourseRawsFromHtml(pageHtml);
  completePostgraduateCourseRawFromPostgraduateScoreRaw(courseList, resultList);
  return parsePostgraduateTimetableFromCourseRaw(
    courseList,
    campus: campus,
    studentId: studentId,
  );
}

List<PostgraduateCourseRaw> parsePostgraduateCourseRawsFromHtml(String timetableHtmlContent) {
  List<List<int>> generateTimetable() {
    List<List<int>> timetable = [];
    for (int i = 0; i < 9; i++) {
      List<int> timeslots = List.generate(14, (index) => -1);
      timetable.add(timeslots);
    }
    return timetable;
  }

  List<PostgraduateCourseRaw> courseList = [];
  List<List<int>> timetable = generateTimetable();
  const mapOfWeekday = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  final courseCodeRegExp = RegExp(r"(.*?)(学硕\d+班|专硕\d+班|\d+班)$");
  final weekTextRegExp = RegExp(r"([\d-]+周(\([^)]*\))?)([\d-]+节)");

  int parseWeekdayCodeFromIndex(int index, int row, {bool isFirst = false, int rowspan = 1}) {
    if (!isFirst) {
      index = index + 1;
    }
    for (int i = 0; i <= index; i++) {
      if (timetable[i][row] != -1 && timetable[i][row] != row) {
        index++;
      }
    }
    for (int r = 0; r < rowspan; r++) {
      timetable[index][row + r] = row;
    }
    return index - 2;
  }

  void processNodes(List nodes, String weekday) {
    if (nodes.length < 5) {
      // 如果节点数量小于 5，不足以构成一个完整的 Course，忽略
      return;
    }

    final locationWithTeacherStr = mapChinesePunctuations(nodes[4].text);
    final locationWithTeacherList = locationWithTeacherStr.split("  ");
    final location = locationWithTeacherList[0];
    final teacher = locationWithTeacherList[1];

    var courseNameWithClassCode = mapChinesePunctuations(nodes[0].text);
    final String courseName;
    final String classCode;
    RegExpMatch? courseNameWithClassCodeMatch = courseCodeRegExp.firstMatch(courseNameWithClassCode);
    if (courseNameWithClassCodeMatch != null) {
      courseName = courseNameWithClassCodeMatch.group(1) ?? "";
      classCode = courseNameWithClassCodeMatch.group(2) ?? "";
    } else {
      courseName = courseNameWithClassCode;
      classCode = "";
    }

    var weekTextWithTimeslotsText = mapChinesePunctuations(nodes[2].text);
    final String weekText;
    final String timeslotsText;
    RegExpMatch? weekTextWithTimeslotsTextMatch = weekTextRegExp.firstMatch(weekTextWithTimeslotsText);
    if (weekTextWithTimeslotsTextMatch != null) {
      weekText = weekTextWithTimeslotsTextMatch.group(1) ?? "";
      timeslotsText = weekTextWithTimeslotsTextMatch.group(3) ?? "";
    } else {
      weekText = "";
      timeslotsText = "";
    }

    final course = PostgraduateCourseRaw(
      courseName: courseName,
      weekDayText: weekday,
      weekText: weekText,
      timeslotsText: timeslotsText,
      teachers: teacher,
      place: location,
      classCode: classCode,
      courseCode: "",
      courseCredit: "",
      creditHour: "",
    );

    courseList.add(course);

    // 移除处理过的节点，继续处理剩余的节点
    nodes.removeRange(0, 7);

    if (nodes.isNotEmpty) {
      processNodes(nodes, weekday);
    }
  }

  final document = parse(timetableHtmlContent);
  final table = document.querySelector('table');
  final trList = table!.querySelectorAll('tr');
  for (var tr in trList) {
    final row = trList.indexOf(tr);
    final tdList = tr.querySelectorAll('td');
    for (var td in tdList) {
      String firstTdContent = tdList[0].text;
      bool isFirst = const ["上午", "下午", "晚上"].contains(firstTdContent);
      if (td.innerHtml.contains("br")) {
        final index = tdList.indexOf(td);
        final rowspan = int.parse(td.attributes["rowspan"] ?? "1");
        int weekdayCode = parseWeekdayCodeFromIndex(index, row, isFirst: isFirst, rowspan: rowspan);
        String weekday = mapOfWeekday[weekdayCode];
        final nodes = td.nodes;
        processNodes(nodes, weekday);
      }
    }
  }
  return courseList;
}

void completePostgraduateCourseRawFromPostgraduateScoreRaw(
    List<PostgraduateCourseRaw> courseList, List<ExamResultPgRaw> scoreList) {
  var name2Score = <String, ExamResultPgRaw>{};

  for (var score in scoreList) {
    var key = score.courseName.replaceAll(" ", "");
    name2Score[key] = score;
  }

  for (var course in courseList) {
    var key = course.courseName.replaceAll(" ", "");
    var score = name2Score[key];
    if (score != null) {
      course.courseCode = score.courseCode;
      course.courseCredit = score.credit;
    }
  }
}

Timetable parsePostgraduateTimetableFromCourseRaw(
  List<PostgraduateCourseRaw> all, {
  required Campus campus,
  required String studentId,
}) {
  final courseKey2Entity = <String, Course>{};
  var counter = 0;
  for (final raw in all) {
    final courseKey = counter++;
    final weekIndices = parseWeekText2RangedNumbers(
      mapChinesePunctuations(raw.weekText),
      allSuffix: "周",
      oddSuffix: "周(单周)",
      evenSuffix: "周(双周)",
    );
    final dayIndex = weekday2Index[raw.weekDayText];
    assert(dayIndex != null && 0 <= dayIndex && dayIndex < 7, "dayIndex isn't in range [0,6] but $dayIndex");
    if (dayIndex == null || !(0 <= dayIndex && dayIndex < 7)) continue;
    final timeslotsText = raw.timeslotsText.endsWith("节")
        ? raw.timeslotsText.substring(0, raw.timeslotsText.length - 1)
        : raw.timeslotsText;
    final timeslots = rangeFromString(timeslotsText, number2index: true);
    assert(timeslots.start <= timeslots.end, "${timeslots.start} > ${timeslots.end} actually. ${raw.courseName}");
    final course = Course(
      courseKey: courseKey,
      courseName: mapChinesePunctuations(raw.courseName).trim(),
      courseCode: raw.courseCode.trim(),
      classCode: raw.classCode.trim(),
      place: reformatPlace(mapChinesePunctuations(raw.place)),
      weekIndices: weekIndices,
      timeslots: timeslots,
      courseCredit: double.tryParse(raw.courseCredit) ?? 0.0,
      dayIndex: dayIndex,
      teachers: raw.teachers.split(","),
    );
    courseKey2Entity["$courseKey"] = course;
  }
  final res = Timetable(
    uuid: const Uuid().v4(),
    courses: courseKey2Entity,
    lastCourseKey: counter,
    schoolCode: SchoolCode.sit,
    name: "",
    studentId: studentId,
    studentType: StudentType.postgraduate,
    campus: campus,
    startDate: DateTime.utc(0),
    createdTime: DateTime.now(),
    schoolYear: 0,
    semester: Semester.term1,
    lastModified: DateTime.now(),
  );
  return res;
}
