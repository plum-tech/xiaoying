// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SemesterInfoAdapter extends TypeAdapter<SemesterInfo> {
  @override
  final int typeId = 1;

  @override
  SemesterInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SemesterInfo(
      year: fields[0] as int?,
      semester: fields[1] as Semester,
    );
  }

  @override
  void write(BinaryWriter writer, SemesterInfo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.year)
      ..writeByte(1)
      ..write(obj.semester);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemesterInfoAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class SemesterAdapter extends TypeAdapter<Semester> {
  @override
  final int typeId = 0;

  @override
  Semester read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Semester.all;
      case 1:
        return Semester.term1;
      case 2:
        return Semester.term2;
      default:
        return Semester.all;
    }
  }

  @override
  void write(BinaryWriter writer, Semester obj) {
    switch (obj) {
      case Semester.all:
        writer.writeByte(0);
        break;
      case Semester.term1:
        writer.writeByte(1);
        break;
      case Semester.term2:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SemesterAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class CourseCatAdapter extends TypeAdapter<CourseCat> {
  @override
  final int typeId = 2;

  @override
  CourseCat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CourseCat.none;
      case 1:
        return CourseCat.genEd;
      case 2:
        return CourseCat.publicCore;
      case 3:
        return CourseCat.specializedCore;
      case 4:
        return CourseCat.specializedCompulsory;
      case 5:
        return CourseCat.specializedElective;
      case 6:
        return CourseCat.integratedPractice;
      case 7:
        return CourseCat.practicalInstruction;
      default:
        return CourseCat.none;
    }
  }

  @override
  void write(BinaryWriter writer, CourseCat obj) {
    switch (obj) {
      case CourseCat.none:
        writer.writeByte(0);
        break;
      case CourseCat.genEd:
        writer.writeByte(1);
        break;
      case CourseCat.publicCore:
        writer.writeByte(2);
        break;
      case CourseCat.specializedCore:
        writer.writeByte(3);
        break;
      case CourseCat.specializedCompulsory:
        writer.writeByte(4);
        break;
      case CourseCat.specializedElective:
        writer.writeByte(5);
        break;
      case CourseCat.integratedPractice:
        writer.writeByte(6);
        break;
      case CourseCat.practicalInstruction:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CourseCatAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
