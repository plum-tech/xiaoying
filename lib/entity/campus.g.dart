// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campus.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CampusAdapter extends TypeAdapter<Campus> {
  @override
  final typeId = 3;

  @override
  Campus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Campus.defaultCampus;
      default:
        return Campus.defaultCampus;
    }
  }

  @override
  void write(BinaryWriter writer, Campus obj) {
    switch (obj) {
      case Campus.defaultCampus:
        writer.writeByte(0);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
