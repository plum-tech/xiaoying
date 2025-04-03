// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ElectricityBalanceAdapter extends TypeAdapter<ElectricityBalance> {
  @override
  final int typeId = 60;

  @override
  ElectricityBalance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ElectricityBalance(
      roomNumber: fields[3] as String,
      balance: fields[0] as double,
      baseBalance: fields[1] as double,
      electricityBalance: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ElectricityBalance obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.balance)
      ..writeByte(1)
      ..write(obj.baseBalance)
      ..writeByte(2)
      ..write(obj.electricityBalance)
      ..writeByte(3)
      ..write(obj.roomNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElectricityBalanceAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElectricityBalance _$ElectricityBalanceFromJson(Map<String, dynamic> json) => ElectricityBalance(
      roomNumber: json['RoomName'] as String,
      balance: _parseBalance(json['Balance'] as String),
      baseBalance: _parseBalance(json['BaseBalance'] as String),
      electricityBalance: _parseBalance(json['ElecBalance'] as String),
    );
