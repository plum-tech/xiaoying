import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/utils/date.dart';

part 'exam.g.dart';

String _parseCourseName(dynamic courseName) {
  return mapChinesePunctuations(courseName.toString());
}

String _parsePlace(dynamic place) {
  return mapChinesePunctuations(place.toString());
}

int? _parseSeatNumber(String s) => int.tryParse(s);
final _timeFormat = DateFormat('yyyy-MM-dd hh:mm');

ExamTime? _parseTime(String s) {
  try {
    final date = s.split('(')[0];
    final time = s.split('(')[1].replaceAll(')', '');
    final startRaw = '$date ${time.split('-')[0]}';
    final endRaw = '$date ${time.split('-')[1]}';

    final startTime = _timeFormat.parse(startRaw);
    final endTime = _timeFormat.parse(endRaw);

    return (start: startTime, end: endTime);
  } catch (_) {
    return null;
  }
}

bool _parseRetake(dynamic status) {
  if (status == null) return false;
  return switch (status.toString()) {
    "是" => true,
    "否" => false,
    _ => false,
  };
}

bool _parseDisqualified(dynamic note) {
  if (note is! String) return false;
  return note.contains("取消考试资格");
}

typedef ExamTime = ({DateTime start, DateTime end});

@JsonSerializable()
class ExamEntry {
  /// 课程名称
  @JsonKey()
  final String courseName;

  /// 考试时间. 若无数据, 列表未空.
  @JsonKey()
  final ExamTime? time;

  /// 考试地点
  @JsonKey()
  final String place;

  // TODO: Use Campus enum
  /// 考试校区
  @JsonKey()
  final String campus;

  /// 考试座号
  @JsonKey()
  final int? seatNumber;

  /// 是否重修
  @JsonKey()
  final bool isRetake;

  @JsonKey()
  final bool disqualified;

  const ExamEntry({
    required this.courseName,
    required this.place,
    required this.campus,
    required this.time,
    required this.seatNumber,
    this.isRetake = false,
    this.disqualified = false,
  });

  factory ExamEntry.fromJson(Map<String, dynamic> json) => _$ExamEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ExamEntryToJson(this);

  factory ExamEntry.parseRemoteJson(Map<String, dynamic> json) {
    return ExamEntry(
      courseName: _parseCourseName(json['kcmc']),
      place: _parsePlace(json['cdmc']),
      campus: json['cdxqmc'] as String,
      time: _parseTime(json['kssj'] as String),
      seatNumber: _parseSeatNumber(json['zwh'] as String),
      isRetake: _parseRetake(json['cxbj']),
      disqualified: _parseDisqualified(json['ksbz']),
    );
  }

  @override
  String toString() {
    return {
      "courseName": courseName,
      "time": time,
      "place": place,
      "campus": campus,
      "seatNumber": seatNumber,
      "isRetake": isRetake,
      "disqualified": disqualified,
    }.toString();
  }

  static int compareByTime(ExamEntry a, ExamEntry b) {
    return dateTimeComparator(a.time?.start, b.time?.start);
  }
}

extension ExamEntryX on ExamEntry {
  String buildDate(BuildContext context) {
    final time = this.time;
    assert(time != null);
    if (time == null) return "null";
    final (:start, :end) = time;
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      // at the same day
      return context.formatMdWeekText(start);
    } else {
      return "${context.formatMdNum(start)}–${context.formatMdNum(end)}";
    }
  }

  String buildTime(BuildContext context) {
    final time = this.time;
    assert(time != null);
    if (time == null) return "null";
    final (:start, :end) = time;
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      // at the same day
      return "${context.formatHmNum(start)}–${context.formatHmNum(end)}";
    } else {
      return "${context.formatMdhmNum(start)}–${context.formatMdhmNum(end)}";
    }
  }
}
