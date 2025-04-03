// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OaLoginStatusAdapter extends TypeAdapter<OaLoginStatus> {
  @override
  final int typeId = 5;

  @override
  OaLoginStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OaLoginStatus.never;
      case 2:
        return OaLoginStatus.offline;
      case 3:
        return OaLoginStatus.validated;
      case 4:
        return OaLoginStatus.everLogin;
      default:
        return OaLoginStatus.never;
    }
  }

  @override
  void write(BinaryWriter writer, OaLoginStatus obj) {
    switch (obj) {
      case OaLoginStatus.never:
        writer.writeByte(0);
        break;
      case OaLoginStatus.offline:
        writer.writeByte(2);
        break;
      case OaLoginStatus.validated:
        writer.writeByte(3);
        break;
      case OaLoginStatus.everLogin:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OaLoginStatusAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
