// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attended.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Class2ndScoreSummaryAdapter extends TypeAdapter<Class2ndScoreSummary> {
  @override
  final int typeId = 20;

  @override
  Class2ndScoreSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Class2ndScoreSummary(
      thematicReport: fields[0] as double,
      practice: fields[1] as double,
      creation: fields[2] as double,
      schoolSafetyCivilization: fields[3] as double,
      voluntary: fields[4] as double,
      schoolCulture: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Class2ndScoreSummary obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.thematicReport)
      ..writeByte(1)
      ..write(obj.practice)
      ..writeByte(2)
      ..write(obj.creation)
      ..writeByte(3)
      ..write(obj.schoolSafetyCivilization)
      ..writeByte(4)
      ..write(obj.voluntary)
      ..writeByte(5)
      ..write(obj.schoolCulture);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Class2ndScoreSummaryAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class Class2ndScoreItemAdapter extends TypeAdapter<Class2ndScoreItem> {
  @override
  final int typeId = 22;

  @override
  Class2ndScoreItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Class2ndScoreItem(
      name: fields[0] as String,
      activityId: fields[1] as int,
      category: fields[2] as Class2ndActivityCat,
      time: fields[3] as DateTime?,
      points: fields[4] as double,
      honestyPoints: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Class2ndScoreItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.activityId)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.points)
      ..writeByte(5)
      ..write(obj.honestyPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Class2ndScoreItemAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class Class2ndActivityApplicationAdapter extends TypeAdapter<Class2ndActivityApplication> {
  @override
  final int typeId = 21;

  @override
  Class2ndActivityApplication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Class2ndActivityApplication(
      applicationId: fields[0] as int,
      activityId: fields[1] as int,
      title: fields[2] as String,
      time: fields[3] as DateTime,
      status: fields[4] as String,
      category: fields[5] as Class2ndActivityCat,
    );
  }

  @override
  void write(BinaryWriter writer, Class2ndActivityApplication obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.applicationId)
      ..writeByte(1)
      ..write(obj.activityId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Class2ndActivityApplicationAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class Class2ndScoreTypeAdapter extends TypeAdapter<Class2ndScoreType> {
  @override
  final int typeId = 23;

  @override
  Class2ndScoreType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Class2ndScoreType.thematicReport;
      case 1:
        return Class2ndScoreType.creation;
      case 2:
        return Class2ndScoreType.schoolCulture;
      case 3:
        return Class2ndScoreType.practice;
      case 4:
        return Class2ndScoreType.voluntary;
      case 5:
        return Class2ndScoreType.schoolSafetyCivilization;
      default:
        return Class2ndScoreType.thematicReport;
    }
  }

  @override
  void write(BinaryWriter writer, Class2ndScoreType obj) {
    switch (obj) {
      case Class2ndScoreType.thematicReport:
        writer.writeByte(0);
        break;
      case Class2ndScoreType.creation:
        writer.writeByte(1);
        break;
      case Class2ndScoreType.schoolCulture:
        writer.writeByte(2);
        break;
      case Class2ndScoreType.practice:
        writer.writeByte(3);
        break;
      case Class2ndScoreType.voluntary:
        writer.writeByte(4);
        break;
      case Class2ndScoreType.schoolSafetyCivilization:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Class2ndScoreTypeAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
