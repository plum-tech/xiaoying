// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.pg.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamResultPgAdapter extends TypeAdapter<ExamResultPg> {
  @override
  final int typeId = 23;

  @override
  ExamResultPg read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamResultPg(
      courseType: fields[0] as String,
      courseCode: fields[1] as String,
      courseName: fields[2] as String,
      credit: fields[3] as int,
      teacher: fields[4] as String,
      score: fields[5] as double,
      passed: fields[6] as bool,
      examType: fields[7] as String,
      form: fields[8] as String,
      time: fields[9] as DateTime?,
      notes: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExamResultPg obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.courseType)
      ..writeByte(1)
      ..write(obj.courseCode)
      ..writeByte(2)
      ..write(obj.courseName)
      ..writeByte(3)
      ..write(obj.credit)
      ..writeByte(4)
      ..write(obj.teacher)
      ..writeByte(5)
      ..write(obj.score)
      ..writeByte(6)
      ..write(obj.passed)
      ..writeByte(7)
      ..write(obj.examType)
      ..writeByte(8)
      ..write(obj.form)
      ..writeByte(9)
      ..write(obj.time)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamResultPgAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
