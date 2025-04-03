// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TransactionCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Transaction(...).copyWith(id: 12, name: "My name")
  /// ````
  Transaction call({
    DateTime? timestamp,
    int? consumerId,
    TransactionType? type,
    double? balanceBefore,
    double? balanceAfter,
    double? deltaAmount,
    String? deviceName,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTransaction.copyWith(...)`.
class _$TransactionCWProxyImpl implements _$TransactionCWProxy {
  const _$TransactionCWProxyImpl(this._value);

  final Transaction _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Transaction(...).copyWith(id: 12, name: "My name")
  /// ````
  Transaction call({
    Object? timestamp = const $CopyWithPlaceholder(),
    Object? consumerId = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? balanceBefore = const $CopyWithPlaceholder(),
    Object? balanceAfter = const $CopyWithPlaceholder(),
    Object? deltaAmount = const $CopyWithPlaceholder(),
    Object? deviceName = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return Transaction(
      timestamp: timestamp == const $CopyWithPlaceholder() || timestamp == null
          ? _value.timestamp
          // ignore: cast_nullable_to_non_nullable
          : timestamp as DateTime,
      consumerId: consumerId == const $CopyWithPlaceholder() || consumerId == null
          ? _value.consumerId
          // ignore: cast_nullable_to_non_nullable
          : consumerId as int,
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as TransactionType,
      balanceBefore: balanceBefore == const $CopyWithPlaceholder() || balanceBefore == null
          ? _value.balanceBefore
          // ignore: cast_nullable_to_non_nullable
          : balanceBefore as double,
      balanceAfter: balanceAfter == const $CopyWithPlaceholder() || balanceAfter == null
          ? _value.balanceAfter
          // ignore: cast_nullable_to_non_nullable
          : balanceAfter as double,
      deltaAmount: deltaAmount == const $CopyWithPlaceholder() || deltaAmount == null
          ? _value.deltaAmount
          // ignore: cast_nullable_to_non_nullable
          : deltaAmount as double,
      deviceName: deviceName == const $CopyWithPlaceholder() || deviceName == null
          ? _value.deviceName
          // ignore: cast_nullable_to_non_nullable
          : deviceName as String,
      note: note == const $CopyWithPlaceholder() || note == null
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String,
    );
  }
}

extension $TransactionCopyWith on Transaction {
  /// Returns a callable class that can be used as follows: `instanceOfTransaction.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TransactionCWProxy get copyWith => _$TransactionCWProxyImpl(this);
}

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 51;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      timestamp: fields[0] as DateTime,
      consumerId: fields[1] as int,
      type: fields[2] as TransactionType,
      balanceBefore: fields[3] as double,
      balanceAfter: fields[4] as double,
      deltaAmount: fields[5] as double,
      deviceName: fields[6] as String,
      note: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.consumerId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.balanceBefore)
      ..writeByte(4)
      ..write(obj.balanceAfter)
      ..writeByte(5)
      ..write(obj.deltaAmount)
      ..writeByte(6)
      ..write(obj.deviceName)
      ..writeByte(7)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 50;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.water;
      case 1:
        return TransactionType.shower;
      case 2:
        return TransactionType.food;
      case 3:
        return TransactionType.store;
      case 4:
        return TransactionType.topUp;
      case 5:
        return TransactionType.subsidy;
      case 6:
        return TransactionType.coffee;
      case 7:
        return TransactionType.library;
      case 8:
        return TransactionType.other;
      default:
        return TransactionType.water;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.water:
        writer.writeByte(0);
        break;
      case TransactionType.shower:
        writer.writeByte(1);
        break;
      case TransactionType.food:
        writer.writeByte(2);
        break;
      case TransactionType.store:
        writer.writeByte(3);
        break;
      case TransactionType.topUp:
        writer.writeByte(4);
        break;
      case TransactionType.subsidy:
        writer.writeByte(5);
        break;
      case TransactionType.coffee:
        writer.writeByte(6);
        break;
      case TransactionType.library:
        writer.writeByte(7);
        break;
      case TransactionType.other:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
