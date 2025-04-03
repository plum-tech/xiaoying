// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.ug.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExamResultUgCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ExamResultUg(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamResultUg call({
    double? score,
    String? courseName,
    String? courseCode,
    String? innerClassId,
    int? year,
    Semester? semester,
    double? credit,
    String? classCode,
    DateTime? time,
    CourseCat? courseCat,
    UgExamType? examType,
    List<String>? teachers,
    List<ExamResultItem>? items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExamResultUg.copyWith(...)`.
class _$ExamResultUgCWProxyImpl implements _$ExamResultUgCWProxy {
  const _$ExamResultUgCWProxyImpl(this._value);

  final ExamResultUg _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ExamResultUg(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamResultUg call({
    Object? score = const $CopyWithPlaceholder(),
    Object? courseName = const $CopyWithPlaceholder(),
    Object? courseCode = const $CopyWithPlaceholder(),
    Object? innerClassId = const $CopyWithPlaceholder(),
    Object? year = const $CopyWithPlaceholder(),
    Object? semester = const $CopyWithPlaceholder(),
    Object? credit = const $CopyWithPlaceholder(),
    Object? classCode = const $CopyWithPlaceholder(),
    Object? time = const $CopyWithPlaceholder(),
    Object? courseCat = const $CopyWithPlaceholder(),
    Object? examType = const $CopyWithPlaceholder(),
    Object? teachers = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return ExamResultUg(
      score: score == const $CopyWithPlaceholder()
          ? _value.score
          // ignore: cast_nullable_to_non_nullable
          : score as double?,
      courseName: courseName == const $CopyWithPlaceholder() || courseName == null
          ? _value.courseName
          // ignore: cast_nullable_to_non_nullable
          : courseName as String,
      courseCode: courseCode == const $CopyWithPlaceholder() || courseCode == null
          ? _value.courseCode
          // ignore: cast_nullable_to_non_nullable
          : courseCode as String,
      innerClassId: innerClassId == const $CopyWithPlaceholder() || innerClassId == null
          ? _value.innerClassId
          // ignore: cast_nullable_to_non_nullable
          : innerClassId as String,
      year: year == const $CopyWithPlaceholder() || year == null
          ? _value.year
          // ignore: cast_nullable_to_non_nullable
          : year as int,
      semester: semester == const $CopyWithPlaceholder() || semester == null
          ? _value.semester
          // ignore: cast_nullable_to_non_nullable
          : semester as Semester,
      credit: credit == const $CopyWithPlaceholder() || credit == null
          ? _value.credit
          // ignore: cast_nullable_to_non_nullable
          : credit as double,
      classCode: classCode == const $CopyWithPlaceholder() || classCode == null
          ? _value.classCode
          // ignore: cast_nullable_to_non_nullable
          : classCode as String,
      time: time == const $CopyWithPlaceholder()
          ? _value.time
          // ignore: cast_nullable_to_non_nullable
          : time as DateTime?,
      courseCat: courseCat == const $CopyWithPlaceholder() || courseCat == null
          ? _value.courseCat
          // ignore: cast_nullable_to_non_nullable
          : courseCat as CourseCat,
      examType: examType == const $CopyWithPlaceholder() || examType == null
          ? _value.examType
          // ignore: cast_nullable_to_non_nullable
          : examType as UgExamType,
      teachers: teachers == const $CopyWithPlaceholder() || teachers == null
          ? _value.teachers
          // ignore: cast_nullable_to_non_nullable
          : teachers as List<String>,
      items: items == const $CopyWithPlaceholder() || items == null
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<ExamResultItem>,
    );
  }
}

extension $ExamResultUgCopyWith on ExamResultUg {
  /// Returns a callable class that can be used as follows: `instanceOfExamResultUg.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$ExamResultUgCWProxy get copyWith => _$ExamResultUgCWProxyImpl(this);
}

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamResultUgAdapter extends TypeAdapter<ExamResultUg> {
  @override
  final int typeId = 20;

  @override
  ExamResultUg read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamResultUg(
      score: fields[0] as double?,
      courseName: fields[1] as String,
      courseCode: fields[2] as String,
      innerClassId: fields[3] as String,
      year: fields[5] as int,
      semester: fields[6] as Semester,
      credit: fields[7] as double,
      classCode: fields[4] as String,
      time: fields[8] as DateTime?,
      courseCat: fields[9] as CourseCat,
      examType: fields[11] as UgExamType,
      teachers: (fields[10] as List).cast<String>(),
      items: (fields[12] as List).cast<ExamResultItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExamResultUg obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.score)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.courseCode)
      ..writeByte(3)
      ..write(obj.innerClassId)
      ..writeByte(4)
      ..write(obj.classCode)
      ..writeByte(5)
      ..write(obj.year)
      ..writeByte(6)
      ..write(obj.semester)
      ..writeByte(7)
      ..write(obj.credit)
      ..writeByte(8)
      ..write(obj.time)
      ..writeByte(9)
      ..write(obj.courseCat)
      ..writeByte(10)
      ..write(obj.teachers)
      ..writeByte(11)
      ..write(obj.examType)
      ..writeByte(12)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamResultUgAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class ExamResultItemAdapter extends TypeAdapter<ExamResultItem> {
  @override
  final int typeId = 21;

  @override
  ExamResultItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamResultItem(
      scoreType: fields[0] as String,
      percentage: fields[1] as String,
      score: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ExamResultItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.scoreType)
      ..writeByte(1)
      ..write(obj.percentage)
      ..writeByte(3)
      ..write(obj.score);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamResultItemAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class UgExamTypeAdapter extends TypeAdapter<UgExamType> {
  @override
  final int typeId = 22;

  @override
  UgExamType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UgExamType.normal;
      case 1:
        return UgExamType.resit;
      case 2:
        return UgExamType.retake;
      default:
        return UgExamType.normal;
    }
  }

  @override
  void write(BinaryWriter writer, UgExamType obj) {
    switch (obj) {
      case UgExamType.normal:
        writer.writeByte(0);
        break;
      case UgExamType.resit:
        writer.writeByte(1);
        break;
      case UgExamType.retake:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UgExamTypeAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamResultUg _$ExamResultUgFromJson(Map<String, dynamic> json) => ExamResultUg(
      score: double.tryParse(json['cj'] as String),
      courseName: _parseCourseName(json['kcmc']),
      courseCode: json['kch'] as String,
      innerClassId: json['jxb_id'] as String,
      year: _formFieldToSchoolYear(json['xnmmc'] as String),
      semester: _formFieldToSemester(json['xqm'] as String),
      credit: double.parse(json['xf'] as String),
      classCode: json['jxbmc'] as String? ?? '',
      time: _parseTime(json['tjsj']),
      courseCat: CourseCat.parse(json['kclbmc'] as String?),
      examType: UgExamType.parse(json['ksxz'] as String),
      teachers: _parseTeachers(json['jsxm'] as String?),
    );

Map<String, dynamic> _$ExamResultUgToJson(ExamResultUg instance) => <String, dynamic>{
      'cj': instance.score,
      'kcmc': instance.courseName,
      'kch': instance.courseCode,
      'jxb_id': instance.innerClassId,
      'jxbmc': instance.classCode,
      'xnmmc': _schoolYearToFormField(instance.year),
      'xqm': _$SemesterEnumMap[instance.semester]!,
      'xf': instance.credit,
      'kclbmc': _$CourseCatEnumMap[instance.courseCat]!,
      'jsxm': instance.teachers,
      'ksxz': _$UgExamTypeEnumMap[instance.examType]!,
    };

const _$SemesterEnumMap = {
  Semester.all: 'all',
  Semester.term1: 'term1',
  Semester.term2: 'term2',
};

const _$CourseCatEnumMap = {
  CourseCat.none: 'none',
  CourseCat.genEd: 'genEd',
  CourseCat.publicCore: 'publicCore',
  CourseCat.specializedCore: 'specializedCore',
  CourseCat.specializedCompulsory: 'specializedCompulsory',
  CourseCat.specializedElective: 'specializedElective',
  CourseCat.integratedPractice: 'integratedPractice',
  CourseCat.practicalInstruction: 'practicalInstruction',
};

const _$UgExamTypeEnumMap = {
  UgExamType.normal: 'normal',
  UgExamType.resit: 'resit',
  UgExamType.retake: 'retake',
};
