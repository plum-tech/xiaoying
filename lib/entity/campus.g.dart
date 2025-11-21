// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campus.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CampusAdapter extends TypeAdapter<Campus> {
  @override
  final int typeId = 3;

  @override
  Campus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Campus.fengxian;
      case 1:
        return Campus.xuhui;
      default:
        return Campus.fengxian;
    }
  }

  @override
  void write(BinaryWriter writer, Campus obj) {
    switch (obj) {
      case Campus.fengxian:
        writer.writeByte(0);
        break;
      case Campus.xuhui:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CampusAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
