// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announce.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OaAnnounceRecordAdapter extends TypeAdapter<OaAnnounceRecord> {
  @override
  final int typeId = 92;

  @override
  OaAnnounceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OaAnnounceRecord(
      title: fields[0] as String,
      uuid: fields[1] as String,
      catalogId: fields[2] as String,
      dateTime: fields[3] as DateTime,
      departments: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, OaAnnounceRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.uuid)
      ..writeByte(2)
      ..write(obj.catalogId)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.departments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OaAnnounceRecordAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class OaAnnounceDetailsAdapter extends TypeAdapter<OaAnnounceDetails> {
  @override
  final int typeId = 90;

  @override
  OaAnnounceDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OaAnnounceDetails(
      title: fields[0] as String,
      dateTime: fields[1] as DateTime,
      department: fields[2] as String,
      author: fields[3] as String,
      readNumber: fields[4] as int,
      content: fields[5] as String,
      attachments: (fields[6] as List).cast<OaAnnounceAttachment>(),
    );
  }

  @override
  void write(BinaryWriter writer, OaAnnounceDetails obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.dateTime)
      ..writeByte(2)
      ..write(obj.department)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.readNumber)
      ..writeByte(5)
      ..write(obj.content)
      ..writeByte(6)
      ..write(obj.attachments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OaAnnounceDetailsAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class OaAnnounceAttachmentAdapter extends TypeAdapter<OaAnnounceAttachment> {
  @override
  final int typeId = 91;

  @override
  OaAnnounceAttachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OaAnnounceAttachment(
      name: fields[0] as String,
      url: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OaAnnounceAttachment obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OaAnnounceAttachmentAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
