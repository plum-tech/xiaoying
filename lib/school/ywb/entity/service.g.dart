// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class YwbServiceAdapter extends TypeAdapter<YwbService> {
  @override
  final int typeId = 72;

  @override
  YwbService read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YwbService(
      id: fields[0] as String,
      name: fields[1] as String,
      summary: fields[2] as String,
      status: fields[3] as int,
      count: fields[4] as int,
      iconName: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, YwbService obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.summary)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.count)
      ..writeByte(5)
      ..write(obj.iconName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YwbServiceAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class YwbServiceDetailsAdapter extends TypeAdapter<YwbServiceDetails> {
  @override
  final int typeId = 70;

  @override
  YwbServiceDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YwbServiceDetails(
      id: fields[0] as String,
      sections: (fields[1] as List).cast<YwbServiceDetailSection>(),
    );
  }

  @override
  void write(BinaryWriter writer, YwbServiceDetails obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sections);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YwbServiceDetailsAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class YwbServiceDetailSectionAdapter extends TypeAdapter<YwbServiceDetailSection> {
  @override
  final int typeId = 71;

  @override
  YwbServiceDetailSection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YwbServiceDetailSection(
      type: fields[1] as String,
      section: fields[0] as String,
      createTime: fields[2] as DateTime,
      content: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, YwbServiceDetailSection obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.section)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.createTime)
      ..writeByte(3)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YwbServiceDetailSectionAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YwbService _$YwbServiceFromJson(Map<String, dynamic> json) => YwbService(
      id: json['appID'] as String,
      name: json['appName'] as String,
      summary: json['appDescribe'] as String,
      status: (json['appStatus'] as num).toInt(),
      count: (json['appCount'] as num).toInt(),
      iconName: json['appIcon'] as String,
    );

YwbServiceDetailSection _$YwbServiceDetailSectionFromJson(Map<String, dynamic> json) => YwbServiceDetailSection(
      type: json['type'] as String,
      section: json['formName'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      content: json['content'] as String,
    );
