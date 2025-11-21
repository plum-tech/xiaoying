import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mimir/storage/hive/type_id.dart';

part 'school.g.dart';

typedef SchoolYear = int;

@HiveType(typeId: CacheHiveType.semester)
@JsonEnum()
enum Semester implements Comparable<Semester> {
  @HiveField(0)
  all,
  @HiveField(1)
  term1,
  @HiveField(2)
  term2;

  String l10n() => "school.semester.$name".tr();

  @override
  int compareTo(Semester other) {
    if (this == other) return 0;
    if (this == term1) return -1;
    return 1;
  }

  String toUgRegFormField() {
    const mapping = {
      Semester.all: '',
      Semester.term1: '3',
      Semester.term2: '12',
    };
    return mapping[this]!;
  }

  static Semester fromUgRegFormField(String field) {
    const mapping = {
      '': Semester.all,
      '3': Semester.term1,
      '12': Semester.term2,
      // for compatibility
      '1': Semester.term1,
      '2': Semester.term2,
    };
    return mapping[field]!;
  }
}

@HiveType(typeId: CacheHiveType.semesterInfo)
class SemesterInfo implements Comparable<SemesterInfo> {
  /// null means all school year
  @HiveField(0)
  final SchoolYear? year;
  @HiveField(1)
  final Semester semester;

  const SemesterInfo({
    required this.year,
    required this.semester,
  });

  static const all = SemesterInfo(year: null, semester: Semester.all);

  bool get exactlyOne => year != null && semester != Semester.all;

  SchoolYear get exactYear {
    assert(exactlyOne);
    return year ?? DateTime.now().year;
  }

  @override
  String toString() {
    return "$year:$semester";
  }

  static String allYearL10n() => "school.allYear".tr();

  String l10n() {
    final year = this.year;
    if (year == null) {
      return "${allYearL10n()} ${semester.l10n()}";
    } else {
      return "$year–${year + 1} ${semester.l10n()}";
    }
  }

  @override
  bool operator ==(Object other) {
    return other is SemesterInfo &&
        runtimeType == other.runtimeType &&
        year == other.year &&
        semester == other.semester;
  }

  @override
  int get hashCode => Object.hash(year, semester);

  @override
  int compareTo(SemesterInfo other) {
    final yearA = year;
    final yearB = other.year;
    if (yearA != yearB) {
      if (yearA == null) return 1;
      if (yearB == null) return -1;
      return yearA.compareTo(yearB);
    }
    if (semester != other.semester) {
      if (semester == Semester.all) return 1;
      if (other.semester == Semester.all) return -1;
      return semester.compareTo(other.semester);
    }
    return 0;
  }
}

@JsonEnum()
enum StudentType {
  undergraduate,
  postgraduate,
  ;

  static final name2enum = Map.fromEntries(values.map((v) => MapEntry(v.name, v)));

  String l10n() => "school.studentType.$name".tr();
  static String l10nTitle() => "school.studentType.title".tr();
}

@HiveType(typeId: CacheHiveType.courseCat)
enum CourseCat {
  @HiveField(0)
  none,

  /// 通识课
  @HiveField(1)
  genEd,

  /// 公共基础课
  @HiveField(2)
  publicCore,

  /// 学科专业基础课
  @HiveField(3)
  specializedCore,

  /// 专业必修课
  @HiveField(4)
  specializedCompulsory,

  /// 专业选修课
  @HiveField(5)
  specializedElective,

  /// 综合实践
  @HiveField(6)
  integratedPractice,

  /// 实践教学
  @HiveField(7)
  practicalInstruction;

  String l10n() => "school.courseCat.$name".tr();

  static CourseCat parse(String? str) {
    return switch (str) {
      "通识课" => genEd,
      "公共基础课" => publicCore,
      "学科专业基础课" => specializedCore,
      "专业必修课" => specializedCompulsory,
      "专业选修课" => specializedElective,
      "综合实践" => integratedPractice,
      "实践教学" => practicalInstruction,
      _ => none,
    };
  }
}
